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
    <title>列国驿轨系统 高速铁路 - 退票结果</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        /* 闅愯棌body鑳屾櫙鍥剧墖锛岄伩鍏嶅湪瑙嗛鍔犺浇鍓嶆樉绀?*/
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

    // 验证参数
    if(uid == null || uid.isEmpty() || password == null || password.isEmpty() || tk == null || tk.isEmpty()) {
        out.println("<div class='card fade-in' style='max-width: 100%;'>");
        out.println("<div class='alert alert-error'>");
        out.println("<strong>退票失败</strong> 请填写完整信息");
        out.println("</div>");
        out.println("<div class='text-center mt-3'>");
        out.println("<a href='tuipiao.jsp' class='btn btn-primary'>重新退票</a>");
        out.println("</div>");
        out.println("</div>");
    } else {
        System.out.println("开始退票，用户ID: " + uid + ", 车票号: " + tk);
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
                
                // 先验证用户密码
                String verifySql = "SELECT id FROM user WHERE id='" + uid + "' AND password='" + password + "'";
                ResultSet verifyRs = stmt.executeQuery(verifySql);
                if(!verifyRs.next()) {
                    out.println("<div class='card fade-in' style='max-width: 100%;'>");
                    out.println("<div class='alert alert-error'>");
                    out.println("<strong>退票失败</strong> 账号或密码错误");
                    out.println("</div>");
                    out.println("<div class='text-center mt-3'>");
                    out.println("<a href='tuipiao.jsp' class='btn btn-primary'>重新退票</a>");
                    out.println("</div>");
                    out.println("</div>");
                    conn.close();
                    return;
                }
                
                // 先直接查询ticket表，检查车票是否存在且属于该用户
                String sql1 = "SELECT ticketnum, seatnum, trainnum, time, id FROM ticket WHERE id='" + uid + "' AND ticketnum='" + tk + "'";
                System.out.println("查询SQL: " + sql1);
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
                                out.println("<strong>退票失败</strong> 列车已发车，无法退票");
                                out.println("</div>");
                                out.println("<div class='text-center mt-3'>");
                                out.println("<a href='tuipiao.jsp?ticket=" + tk + "&uid=" + uid + "' class='btn btn-primary'>返回</a>");
                                out.println("</div>");
                                out.println("</div>");
                                conn.close();
                                return;
                            }
                        }
                    } catch(Exception e) {
                        System.out.println("时间解析失败: " + e.getMessage());
                        // 如果时间解析失败，继续执行退票
                    }
                }
                
                // 查询trip表获取票价（使用LEFT JOIN，即使没有对应记录也能继续）
                String originalPrice = "0";
                try {
                    String priceSql = "SELECT nowprice FROM trip WHERE trainnum='" + ticketTrainnum + "' AND time='" + ticketTime + "' LIMIT 1";
                    ResultSet priceRs = stmt.executeQuery(priceSql);
                    if(priceRs.next()) {
                        originalPrice = priceRs.getString("nowprice");
                        if(originalPrice == null) originalPrice = "0";
                    }
                    priceRs.close();
                } catch(Exception e) {
                    System.out.println("查询票价失败: " + e.getMessage());
                    originalPrice = "0";
                }
                
                // 调用退票存储过程
                CallableStatement cstmt = conn.prepareCall( "{call DELETE_ticket(?,?)}" );
                cstmt.setString( 1 ,uid);
                cstmt.setString( 2 ,tk);
                cstmt.execute();
                
                // 计算手续费（票价的10%）
                double price = 0;
                try {
                    price = Double.parseDouble(originalPrice);
                } catch(Exception e) {
                    price = 0;
                }
                double refundFee = price * 0.1;
                
                out.println("<div class='card fade-in' style='max-width: 100%;'>");
                out.println("<div class='alert alert-success'>");
                out.println("<strong>退票成功</strong> 退款将原路返回您的支付账户，请留意到账信息");
                out.println("</div>");
                out.println("<div style='background: var(--bg-input); padding: 1.5rem; border-radius: 12px; margin-top: 1rem;'>");
                out.println("<h3 style='margin-bottom: 1rem; color: var(--text-primary);'>退票详情</h3>");
                out.println("<div style='display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem;'>");
                out.println("<div><div style='color: var(--text-secondary); font-size: 0.875rem;'>原票价</div><div style='color: var(--text-primary); font-size: 1rem;'>¥" + String.format("%.2f", price) + "</div></div>");
                out.println("<div><div style='color: var(--text-secondary); font-size: 0.875rem;'>退票手续费（10%）</div><div style='color: #E8C547; font-size: 1.25rem; font-weight: 600;'>¥" + String.format("%.2f", refundFee) + "</div></div>");
                out.println("<div><div style='color: var(--text-secondary); font-size: 0.875rem;'>退款金额</div><div style='color: var(--accent-blue); font-size: 1.25rem; font-weight: 600;'>¥" + String.format("%.2f", price - refundFee) + "</div></div>");
                out.println("</div>");
                out.println("</div>");
                out.println("<div class='text-center mt-3'>");
                out.println("<a href='tuipiao.jsp' class='btn btn-primary'>继续退票</a>");
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
                
                System.out.println("退票失败 - " + debugInfo);
                
                out.println("<div class='card fade-in' style='max-width: 100%;'>");
                out.println("<div class='alert alert-error'>");
                out.println("<strong>退票失败</strong> 未找到该车票，请检查：<br>1. 车票号是否正确<br>2. 该车票是否属于您的账号<br><br><small style='color: var(--text-muted);'>" + debugInfo + "</small>");
                out.println("</div>");
                out.println("<div class='text-center mt-3'>");
                out.println("<a href='tuipiao.jsp?ticket=" + tk + "&uid=" + uid + "' class='btn btn-primary'>重新退票</a>");
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
            out.println("<div class='card fade-in' style='max-width: 100%;'>");
            out.println("<div class='alert alert-error'>");
            out.println("<strong>系统错误</strong> 请稍后重试");
            out.println("</div>");
            out.println("</div>");
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<div class='card fade-in' style='max-width: 100%;'>");
            out.println("<div class='alert alert-error'>");
            out.println("<strong>系统错误</strong> " + e.getMessage());
            out.println("</div>");
            out.println("</div>");
        }
    }
%>
    </div>
</body>
</html>