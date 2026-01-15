<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/11/23
  Time: 21:51
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.sql.Connection,
java.sql.DriverManager,
java.sql.Statement,
java.sql.ResultSet,
java.sql.SQLException,
java.sql.CallableStatement,
java.io.FileInputStream,
java.io.FileNotFoundException,
java.io.FileOutputStream,
java.io.IOException,
java.util.Random,
java.io.File ,
java.io.Writer,
java.io.FileWriter ,
java.sql.*" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 改签结果</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        body {
            background-image: none !important;
            background-color: #000000 !important;
        }
        
        .video-background {
             position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            object-fit: cover;
            opacity: 1;
        }
        
        /* 深色背景下的文字样式 */
        .page-title {
            color: #E8C547 !important;
            text-shadow: 0 2px 8px rgba(232, 197, 71, 0.5), 0 0 20px rgba(232, 197, 71, 0.3) !important;
        }
        
        .page-subtitle {
            color: #E0E0DB !important;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5) !important;
        }
        
        .card-title {
            color: #E8C547 !important;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3) !important;
        }
    </style>
</head>
<body>
    <video class="video-background" autoplay muted loop playsinline preload="auto">
        <source src="Star_Rail_Wallpaper.mp4" type="video/mp4">
    </video>
    <%
        String uid = request.getParameter("id");
        if(uid == null) {
            uid = (String)session.getAttribute("user_id");
        }
        if(uid == null) uid = "";
        String homeLink = uid != null && !uid.isEmpty() ? "loginsuccess.jsp?message=" + uid : "loginsuccess.jsp";
    %>
    <nav class="navbar">
        <a href="<%=homeLink%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="<%=homeLink%>">首页</a></li>
            <li><a href="chepiaochaxun.jsp?uid=<%=uid%>">车票查询</a></li>
            <li><a href="tuipiao.jsp">退票</a></li>
            <li><a href="gaipiao.jsp?uid=<%=uid%>">改签</a></li>
            <li><a href="searchrecord.jsp">我的订单</a></li>
            <li><a href="view_trainlist.jsp?uid=<%=uid%>">车次列表</a></li>
            <li><a href="permission_request_list.jsp?uid=<%=uid%>">权限代理</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
<%
    String password=request.getParameter("password");
    String tk=request.getParameter("ticket");
    String newTrain=request.getParameter("new_train");
    String newTimeParam=request.getParameter("new_time"); // 从datetime-local获取的时间（格式：YYYY-MM-DDTHH:MM）
    
    // 将 datetime-local 格式转换为数据库格式（YYYY-MM-DD HH:MM:SS）
    String newTime = "";
    if(newTimeParam != null && !newTimeParam.isEmpty()) {
        // datetime-local 格式：YYYY-MM-DDTHH:MM，需要转换为 YYYY-MM-DD HH:MM:SS
        newTime = newTimeParam.replace("T", " ") + ":00";
    }

    System.out.println("开始改签");
    try {
        // 加载数据库驱动，注册到驱动管理器
        Class.forName("com.mysql.jdbc.Driver");
        // 数据库连接字符串
        String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
        // 数据库用户名
        String usename = "root";
        // 数据库密码
        String psw = "bei060805";
        // 创建Connection连接
        Connection conn = DriverManager.getConnection(url,usename,psw);
        // 判断 数据库连接是否为空
        if(conn != null){
            Statement stmt = conn.createStatement();
            
            // 验证用户密码
            String verifySql = "SELECT id FROM user WHERE id='" + uid + "' AND password='" + password + "'";
            ResultSet verifyRs = stmt.executeQuery(verifySql);
            if(!verifyRs.next()) {
                out.println("<div class='card fade-in' style='max-width: 100%;'>");
                out.println("<div class='alert alert-error'>");
                out.println("<strong>改签失败</strong> 账号或密码错误");
                out.println("</div>");
                out.println("<div class='text-center mt-3'>");
                out.println("<a href='gaipiao.jsp' class='btn btn-primary'>重新改签</a>");
                out.println("</div>");
                out.println("</div>");
                conn.close();
                return;
            }
            
            // 先直接查询ticket表，检查车票是否存在且属于该用户
            String sql1 = "SELECT ticketnum, seatnum, trainnum, time, id FROM ticket WHERE id='" + uid + "' AND ticketnum='" + tk + "'";
            System.out.println("改签查询SQL: " + sql1);
            ResultSet rs1 = stmt.executeQuery(sql1);

            if(rs1.next()){
                // 获取车票信息
                String ticketTrainnum = rs1.getString("trainnum");
                String ticketTime = rs1.getString("time");
                
                System.out.println("找到车票: trainnum=" + ticketTrainnum + ", time=" + ticketTime);
                
                // 检查是否已发车
                if(ticketTime != null && !ticketTime.isEmpty()) {
                    try {
                        // 尝试解析时间（可能是VARCHAR格式）
                        java.sql.Timestamp departTime = null;
                        if(ticketTime.length() >= 16) {
                            // 格式可能是 "YYYY-MM-DD HH:MM:SS" 或 "YYYY-MM-DD HH:MM"
                            departTime = java.sql.Timestamp.valueOf(ticketTime.length() == 19 ? ticketTime : ticketTime + ":00");
                        } else if(ticketTime.length() == 10) {
                            // 格式是 "YYYY-MM-DD"
                            departTime = java.sql.Timestamp.valueOf(ticketTime + " 00:00:00");
                        }
                        
                        if(departTime != null) {
                            java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
                            if(now.after(departTime) || now.equals(departTime)) {
                                out.println("<div class='card fade-in' style='max-width: 100%;'>");
                                out.println("<div class='alert alert-error'>");
                                out.println("<strong>改签失败</strong> 列车已发车，无法改签");
                                out.println("</div>");
                                out.println("<div class='text-center mt-3'>");
                                out.println("<a href='gaipiao.jsp?ticket=" + tk + "&uid=" + uid + "' class='btn btn-primary'>返回</a>");
                                out.println("</div>");
                                out.println("</div>");
                                conn.close();
                                return;
                            }
                        }
                    } catch(Exception e) {
                        System.out.println("时间解析失败: " + e.getMessage());
                        // 如果时间解析失败，继续执行改签
                    }
                }
                
                // 检查新车次和时间是否存在且有票
                System.out.println("检查新车次和时间: trainnum=" + newTrain + ", time=" + newTime);
                
                // 先检查车次是否存在
                String checkTrainSql = "SELECT trainnum FROM train WHERE trainnum='" + newTrain + "'";
                ResultSet checkTrainRs = stmt.executeQuery(checkTrainSql);
                if(!checkTrainRs.next()) {
                    out.println("<div class='card fade-in' style='max-width: 100%;'>");
                    out.println("<div class='alert alert-error'>");
                    out.println("<strong>改签失败</strong> 新车次不存在");
                    out.println("</div>");
                    out.println("<div class='text-center mt-3'>");
                    out.println("<a href='gaipiao.jsp?ticket=" + tk + "&uid=" + uid + "' class='btn btn-primary'>重新改签</a>");
                    out.println("</div>");
                    out.println("</div>");
                    checkTrainRs.close();
                    conn.close();
                    return;
                }
                checkTrainRs.close();
                
                // 检查该车次在该时间是否有运行班次且有票
                // 注意：trip表的time字段是VARCHAR，需要灵活匹配
                // 先尝试精确匹配（带秒）
                String checkNewTripSql = "SELECT time, nowmem, nowprice FROM trip WHERE trainnum='" + newTrain + "' AND time='" + newTime + "' AND nowmem > 0";
                System.out.println("查询SQL (精确匹配): " + checkNewTripSql);
                ResultSet checkRs = stmt.executeQuery(checkNewTripSql);
                
                String actualTime = null;
                int availableSeats = 0;
                
                // 如果精确匹配成功
                if(checkRs.next()) {
                    actualTime = checkRs.getString("time");
                    availableSeats = checkRs.getInt("nowmem");
                    System.out.println("精确匹配成功，时间: " + actualTime + ", 余票: " + availableSeats);
                } else {
                    // 如果精确匹配失败，尝试不带秒的格式（YYYY-MM-DD HH:MM）
                    String newTimeWithoutSeconds = newTime.substring(0, 16); // 去掉 ":00"
                    checkNewTripSql = "SELECT time, nowmem, nowprice FROM trip WHERE trainnum='" + newTrain + "' AND time='" + newTimeWithoutSeconds + "' AND nowmem > 0";
                    System.out.println("查询SQL (不带秒): " + checkNewTripSql);
                    checkRs = stmt.executeQuery(checkNewTripSql);
                    
                    if(checkRs.next()) {
                        actualTime = checkRs.getString("time");
                        availableSeats = checkRs.getInt("nowmem");
                        System.out.println("不带秒匹配成功，时间: " + actualTime + ", 余票: " + availableSeats);
                    } else {
                        // 如果还是失败，尝试使用 LIKE 匹配（匹配日期和时间，忽略秒）
                        String timePattern = newTime.substring(0, 16) + "%"; // 匹配 YYYY-MM-DD HH:MM 开头的所有格式
                        checkNewTripSql = "SELECT time, nowmem, nowprice FROM trip WHERE trainnum='" + newTrain + "' AND time LIKE '" + timePattern + "' AND nowmem > 0 LIMIT 1";
                        System.out.println("查询SQL (LIKE匹配): " + checkNewTripSql);
                        checkRs = stmt.executeQuery(checkNewTripSql);
                        
                        if(checkRs.next()) {
                            actualTime = checkRs.getString("time");
                            availableSeats = checkRs.getInt("nowmem");
                            System.out.println("LIKE匹配成功，时间: " + actualTime + ", 余票: " + availableSeats);
                        }
                    }
                }
                
                // 如果所有匹配方式都失败
                if(actualTime == null) {
                    // 查询该车次在该日期附近的所有班次（用于调试）
                    String debugSql = "SELECT time, nowmem FROM trip WHERE trainnum='" + newTrain + "' AND DATE(time)='" + newTime.substring(0, 10) + "' ORDER BY time";
                    ResultSet debugRs = stmt.executeQuery(debugSql);
                    String debugInfo = "该车次在 " + newTime.substring(0, 10) + " 的可用班次：";
                    boolean hasTrips = false;
                    while(debugRs.next()) {
                        hasTrips = true;
                        String dbTime = debugRs.getString("time");
                        debugInfo += "\n" + dbTime + " (余票: " + debugRs.getString("nowmem") + ")";
                    }
                    debugRs.close();
                    
                    if(!hasTrips) {
                        debugInfo = "该车次在 " + newTime.substring(0, 10) + " 没有运行班次";
                    }
                    
                    System.out.println("改签失败 - 查询的时间: " + newTime + ", " + debugInfo);
                    
                    out.println("<div class='card fade-in' style='max-width: 100%;'>");
                    out.println("<div class='alert alert-error'>");
                    out.println("<strong>改签失败</strong> 新车次或发车时间不存在，或已无余票<br><br>");
                    out.println("<small style='color: var(--text-muted);'>" + debugInfo.replace("\n", "<br>") + "</small>");
                    out.println("</div>");
                    out.println("<div class='text-center mt-3'>");
                    out.println("<a href='gaipiao.jsp?ticket=" + tk + "&uid=" + uid + "' class='btn btn-primary'>重新改签</a>");
                    out.println("</div>");
                    out.println("</div>");
                    conn.close();
                    return;
                }
                
                // 使用数据库中实际的时间格式来调用存储过程
                newTime = actualTime;
                System.out.println("最终使用的时间格式: " + newTime + ", 余票: " + availableSeats);
                
                // 调用改签存储过程
                CallableStatement cstmt = conn.prepareCall( "{call CHANGE_TICKET(?,?,?)}" );
                cstmt.setString( 1 ,tk);
                cstmt.setString( 2 ,newTrain);
                cstmt.setString( 3 ,newTime);
                cstmt.execute();
                cstmt.close();
                
                System.out.println("改签存储过程执行完成");
                
                // 查询改签后的车票信息
                // 注意：CHANGE_TICKET 存储过程会删除旧票并创建新票，新票号是自动生成的
                // 所以我们需要查询该用户最新的车票（按 ticketnum 降序排列的第一条）
                // 避免使用 IN (SELECT ... LIMIT 1)，改用 JOIN 或先查询 ticketnum
                
                // 方法1：先查询最新的 ticketnum
                String latestTicketSql = "SELECT ticketnum FROM ticket WHERE id='" + uid + "' ORDER BY ticketnum DESC LIMIT 1";
                ResultSet latestRs = stmt.executeQuery(latestTicketSql);
                String newTicketNum = tk; // 默认使用原票号（如果存储过程更新了原票）
                if(latestRs.next()) {
                    newTicketNum = latestRs.getString("ticketnum");
                }
                latestRs.close();
                
                // 方法2：查询改签后的车票详细信息（使用新的 ticketnum）
                String newTicketSql = "SELECT t.ticketnum, t.trainnum, t.time, tr.nowprice FROM ticket t JOIN trip tr ON t.trainnum=tr.trainnum AND t.time=tr.time WHERE t.ticketnum='" + newTicketNum + "' AND t.id='" + uid + "'";
                System.out.println("查询改签后车票SQL: " + newTicketSql);
                ResultSet newTicketRs = stmt.executeQuery(newTicketSql);
                
                String newPrice = "";
                String actualNewTrain = newTrain;
                String actualNewTime = newTime;
                if(newTicketRs.next()) {
                    newTicketNum = newTicketRs.getString("ticketnum");
                    newPrice = newTicketRs.getString("nowprice");
                    actualNewTrain = newTicketRs.getString("trainnum");
                    actualNewTime = newTicketRs.getString("time");
                    System.out.println("改签成功 - 新车票号: " + newTicketNum + ", 新车次: " + actualNewTrain + ", 新时间: " + actualNewTime + ", 新价格: " + newPrice);
                } else {
                    // 如果查询不到，尝试直接查询该用户、新车次、新时间的车票
                    String fallbackSql = "SELECT t.ticketnum, t.trainnum, t.time, tr.nowprice FROM ticket t JOIN trip tr ON t.trainnum=tr.trainnum AND t.time=tr.time WHERE t.id='" + uid + "' AND t.trainnum='" + newTrain + "' AND t.time='" + newTime + "' ORDER BY t.ticketnum DESC LIMIT 1";
                    ResultSet fallbackRs = stmt.executeQuery(fallbackSql);
                    if(fallbackRs.next()) {
                        newTicketNum = fallbackRs.getString("ticketnum");
                        newPrice = fallbackRs.getString("nowprice");
                        actualNewTrain = fallbackRs.getString("trainnum");
                        actualNewTime = fallbackRs.getString("time");
                        System.out.println("使用备用查询 - 新车票号: " + newTicketNum);
                    }
                    fallbackRs.close();
                }
                newTicketRs.close();
                
                out.println("<div class='card fade-in' style='max-width: 100%;'>");
                out.println("<div class='alert alert-success'>");
                out.println("<strong>改签成功</strong> 您的车票已成功改签");
                out.println("</div>");
                out.println("<div style='background: var(--bg-input); padding: 1.5rem; border-radius: 12px; margin-top: 1rem;'>");
                out.println("<h3 style='margin-bottom: 1rem; color: var(--text-primary);'>改签详情</h3>");
                out.println("<div style='display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem;'>");
                out.println("<div><div style='color: var(--text-secondary); font-size: 0.875rem;'>新车票号</div><div style='color: var(--text-primary); font-size: 1rem; font-weight: 600;'>" + newTicketNum + "</div></div>");
                out.println("<div><div style='color: var(--text-secondary); font-size: 0.875rem;'>新车次</div><div style='color: var(--text-primary); font-size: 1rem;'>" + actualNewTrain + "</div></div>");
                out.println("<div><div style='color: var(--text-secondary); font-size: 0.875rem;'>新发车时间</div><div style='color: var(--text-primary); font-size: 1rem;'>" + actualNewTime + "</div></div>");
                out.println("<div><div style='color: var(--text-secondary); font-size: 0.875rem;'>新票价</div><div style='color: var(--accent-blue); font-size: 1.25rem; font-weight: 600;'>¥" + newPrice + "</div></div>");
                
                // 验证数据库更新情况
                try {
                    // 检查原车票是否已删除
                    String checkOldTicketSql = "SELECT COUNT(*) as count FROM ticket WHERE ticketnum='" + tk + "'";
                    ResultSet checkOldRs = stmt.executeQuery(checkOldTicketSql);
                    int oldTicketExists = 0;
                    if(checkOldRs.next()) {
                        oldTicketExists = checkOldRs.getInt("count");
                    }
                    checkOldRs.close();
                    
                    // 检查新车票是否存在
                    String checkNewTicketSql = "SELECT COUNT(*) as count FROM ticket WHERE ticketnum='" + newTicketNum + "'";
                    ResultSet checkNewRs = stmt.executeQuery(checkNewTicketSql);
                    int newTicketExists = 0;
                    if(checkNewRs.next()) {
                        newTicketExists = checkNewRs.getInt("count");
                    }
                    checkNewRs.close();
                    
                    // 检查新班次的余票是否减少
                    String checkSeatsSql = "SELECT nowmem FROM trip WHERE trainnum='" + actualNewTrain + "' AND time='" + actualNewTime + "'";
                    ResultSet seatsRs = stmt.executeQuery(checkSeatsSql);
                    String remainingSeats = "未知";
                    if(seatsRs.next()) {
                        remainingSeats = seatsRs.getString("nowmem");
                    }
                    seatsRs.close();
                    
                    System.out.println("数据库验证 - 原车票存在: " + (oldTicketExists > 0 ? "是" : "否") + 
                                     ", 新车票存在: " + (newTicketExists > 0 ? "是" : "否") + 
                                     ", 新班次余票: " + remainingSeats);
                } catch(Exception e) {
                    System.out.println("数据库验证失败: " + e.getMessage());
                }
                out.println("</div>");
                out.println("</div>");
                out.println("<div class='text-center mt-3'>");
                out.println("<a href='gaipiao.jsp' class='btn btn-primary'>继续改签</a>");
                out.println("<a href='searchrecord.jsp' class='btn btn-secondary'>查看订单</a>");
                out.println("</div>");
                out.println("</div>");
            }else{
                // 调试：检查车票是否存在（不检查用户）
                String debugSql = "SELECT ticketnum, id FROM ticket WHERE ticketnum='" + tk + "'";
                ResultSet debugRs = stmt.executeQuery(debugSql);
                String debugInfo = "";
                if(debugRs.next()) {
                    String ticketUserId = debugRs.getString("id");
                    debugInfo = "车票存在，但属于用户: " + ticketUserId + "，当前用户: " + uid;
                } else {
                    debugInfo = "车票号不存在";
                }
                debugRs.close();
                
                System.out.println("改签失败 - " + debugInfo);
                
                out.println("<div class='card fade-in' style='max-width: 100%;'>");
                out.println("<div class='alert alert-error'>");
                out.println("<strong>改签失败</strong> 未找到该车票，请检查：<br>1. 车票号是否正确<br>2. 该车票是否属于您的账号<br><br><small style='color: var(--text-muted);'>" + debugInfo + "</small>");
                out.println("</div>");
                out.println("<div class='text-center mt-3'>");
                out.println("<a href='gaipiao.jsp?ticket=" + tk + "&uid=" + uid + "' class='btn btn-primary'>重新改签</a>");
                out.println("</div>");
                out.println("</div>");
            }
            conn.close();
        }else{
            out.println("<div class='card fade-in' style='max-width: 100%;'>");
            out.println("<div class='alert alert-error'>");
            out.println("<strong>系统错误</strong> 数据库连接失败，请稍后重试");
            out.println("</div>");
            out.println("</div>");
        }
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
        out.println("<div class='card fade-in'>");
        out.println("<div class='alert alert-error'>");
        out.println("<strong>系统错误</strong> 请稍后重试");
        out.println("</div>");
        out.println("</div>");
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<div class='card fade-in'>");
        out.println("<div class='alert alert-error'>");
        out.println("<strong>系统错误</strong> " + e.getMessage());
        out.println("</div>");
        out.println("</div>");
    }
%>
    </div>
</body>
</html>

