<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/12/1
  Time: 15:08
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.sql.*,java.io.*,java.util.*"%>
<%@ page contentType="text/html;charset=utf-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 查询结果</title>
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
        request.setCharacterEncoding("utf-8");
        String uid = request.getParameter("uid");
        if(uid == null) {
            uid = (String)session.getAttribute("user_id");
        }
        if(uid == null) uid = "";
        String homeLink = uid != null && !uid.isEmpty() ? "loginsuccess.jsp?message=" + uid : "loginsuccess.jsp";
        
        String origin=request.getParameter("origin");
        String destination=request.getParameter("destination");
        
        // 优先从depart_date获取日期（日期选择器直接提交的值）
        String departDate = request.getParameter("depart_date");
        String time = "";
        
        if(departDate != null && !departDate.isEmpty()) {
            // 如果depart_date存在，直接使用（格式：YYYY-MM-DD）
            time = departDate;
        } else {
            // 否则从year、month、day组合
            String year=request.getParameter("year");
            String month=request.getParameter("month");
            String day=request.getParameter("day");
            
            if(year != null && month != null && day != null) {
                // 格式化日期，确保月份和日期是两位数
                String monthFormatted = (month.length() == 1) ? "0" + month : month;
                String dayFormatted = (day.length() == 1) ? "0" + day : day;
                time = year + "-" + monthFormatted + "-" + dayFormatted;
            }
        }
        
        // 调试信息（可以删除）
        // out.println("<!-- Debug: origin=" + origin + ", destination=" + destination + ", time=" + time + " -->");
    %>
    <nav class="navbar">
        <a href="<%=homeLink%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="<%=homeLink%>">首页</a></li>
            <li><a href="chepiaochaxun.jsp?uid=<%=uid%>">车票查询</a></li>
            <li><a href="tuipiao.jsp">退票</a></li>
            <li><a href="gaipiao.jsp?uid=<%=uid%>">改签</a></li>
            <li><a href="searchrecord.jsp">我的订单</a></li>
            <li><a href="permission_request_list.jsp?uid=<%=uid%>">权限代理</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">车票查询结果</h1>
        <p class="page-subtitle">为您找到以下可用车次</p>
    <%
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
        Statement stmt = conn.createStatement();
        
        // 验证参数
        if(origin == null || origin.isEmpty() || destination == null || destination.isEmpty() || time == null || time.isEmpty()) {
            out.println("<div class='alert alert-error'>查询参数不完整，请重新输入！</div>");
            out.println("<div style='text-align: center; margin-top: 2rem;'><a href='chepiaochaxun.jsp?uid=" + uid + "' class='btn btn-primary'>返回查询</a></div>");
        } else {
            // 调用直达查询存储过程
            CallableStatement cstmtDirect = conn.prepareCall( "{call SEARCH_DIRECT(?,?,?)}" );
            cstmtDirect.setString( 1 ,origin);
            cstmtDirect.setString( 2 ,destination);
            cstmtDirect.setString( 3 ,time);
            ResultSet rsDirect = cstmtDirect.executeQuery();
            
            // 调用换乘查询存储过程
            CallableStatement cstmtTransfer = conn.prepareCall( "{call SEARCH_TRANSFER(?,?,?)}" );
            cstmtTransfer.setString( 1 ,origin);
            cstmtTransfer.setString( 2 ,destination);
            cstmtTransfer.setString( 3 ,time);
            ResultSet rsTransfer = cstmtTransfer.executeQuery();

    %>
        <!-- 直达车次 -->
        <div class="card fade-in" style="margin-bottom: 2rem; max-width: 100%;">
            <h2 class="card-title" style="margin-bottom: 1.5rem;">直达车次</h2>
            <div class="data-table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>车次</th>
                            <th>车型</th>
                            <th>出发地</th>
                            <th>目的地</th>
                            <th>发车时间</th>
                            <th>价格（元）</th>
                            <th>余票</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                <%
                    boolean hasDirectResult = false;
                    while (rsDirect.next()) {
                        hasDirectResult = true;
                        String tn=rsDirect.getString(1);
                        String ori=rsDirect.getString(2);
                        String des=rsDirect.getString(3);
                        String tim=rsDirect.getString(4);
                        String pri=rsDirect.getString(5);
                        String nowm=rsDirect.getString(6);
                        
                        // 从车次号判断车型
                        String trainTypeName = "-";
                        if(tn != null && tn.length() > 0) {
                            char firstChar = tn.charAt(0);
                            if(firstChar == 'G') trainTypeName = "高铁";
                            else if(firstChar == 'D') trainTypeName = "动车";
                            else if(firstChar == 'C') trainTypeName = "城际";
                            else trainTypeName = String.valueOf(firstChar);
                        }
                        
                        int ticketCount = Integer.parseInt(nowm);
                        String ticketClass = ticketCount <= 5 ? "warning" : "";
                %>
                        <tr>
                            <td class="highlight"><strong><%out.print(tn);%></strong></td>
                            <td><span style="color: #E8C547; font-weight: 600;"><%out.print(trainTypeName);%></span></td>
                            <td><%out.print(ori);%></td>
                            <td><%out.print(des);%></td>
                            <td class="highlight"><%out.print(tim);%></td>
                            <td><strong style="color: var(--accent-blue); font-size: 1.1rem;">¥<%out.print(pri);%></strong></td>
                            <td class="<%=ticketClass%>"><strong><%out.print(nowm);%> 张</strong></td>
                            <td><a href="buying.jsp?trainnum=<%=tn%>&time=<%=tim%>&o=<%=origin%>&d=<%=destination%>&p=<%=pri%>&uid=<%=uid%>" class="link link-primary">立即购买</a></td>
                        </tr>
                <%
                    }
                    if (!hasDirectResult) {
                %>
                        <tr>
                            <td colspan="8" class="empty-state">
                                <div class="empty-state-icon">🚄</div>
                                <div class="empty-state-title">暂无直达车次</div>
                            </td>
                        </tr>
                <%
                    }
                %>
                    </tbody>
                </table>
            </div>
        </div>
        
        <!-- 换乘车次 -->
        <div class="card fade-in" style="max-width: 100%;">
            <h2 class="card-title" style="margin-bottom: 1.5rem;">换乘车次</h2>
            <div class="data-table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>第一段车次</th>
                            <th>出发地</th>
                            <th>换乘站</th>
                            <th>第一段发车时间</th>
                            <th>第二段车次</th>
                            <th>目的地</th>
                            <th>第二段发车时间</th>
                            <th>总票价（元）</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                <%
                    boolean hasTransferResult = false;
                    while (rsTransfer.next()) {
                        hasTransferResult = true;
                        String firstTrain=rsTransfer.getString(1);
                        String ori=rsTransfer.getString(2);
                        String transferStation=rsTransfer.getString(3);
                        String firstDepart=rsTransfer.getString(4);
                        String secondTrain=rsTransfer.getString(5);
                        String des=rsTransfer.getString(6);
                        String secondDepart=rsTransfer.getString(7);
                        String totalPrice=rsTransfer.getString(8);
                        
                        // 查询第一段和第二段的单独价格
                        String firstPriceSql = "SELECT nowprice FROM trip WHERE trainnum='" + firstTrain + "' AND time='" + firstDepart + "'";
                        ResultSet firstPriceRs = stmt.executeQuery(firstPriceSql);
                        String firstPrice = "0";
                        if(firstPriceRs.next()) {
                            firstPrice = firstPriceRs.getString(1);
                        }
                        firstPriceRs.close();
                        
                        String secondPriceSql = "SELECT nowprice FROM trip WHERE trainnum='" + secondTrain + "' AND time='" + secondDepart + "'";
                        ResultSet secondPriceRs = stmt.executeQuery(secondPriceSql);
                        String secondPrice = "0";
                        if(secondPriceRs.next()) {
                            secondPrice = secondPriceRs.getString(1);
                        }
                        secondPriceRs.close();
                %>
                        <tr>
                            <td class="highlight"><strong><%out.print(firstTrain);%></strong></td>
                            <td><%out.print(ori);%></td>
                            <td><span style="color: #E8C547; font-weight: 600;"><%out.print(transferStation);%></span></td>
                            <td class="highlight"><%out.print(firstDepart);%></td>
                            <td class="highlight"><strong><%out.print(secondTrain);%></strong></td>
                            <td><%out.print(des);%></td>
                            <td class="highlight"><%out.print(secondDepart);%></td>
                            <td><strong style="color: var(--accent-blue); font-size: 1.1rem;">¥<%out.print(totalPrice);%></strong></td>
                            <td>
                                <a href="buying.jsp?trainnum=<%=firstTrain%>&time=<%=firstDepart%>&o=<%=ori%>&d=<%=transferStation%>&p=<%=firstPrice%>&uid=<%=uid%>" class="link link-primary">购买第一段</a>
                                <br>
                                <a href="buying.jsp?trainnum=<%=secondTrain%>&time=<%=secondDepart%>&o=<%=transferStation%>&d=<%=des%>&p=<%=secondPrice%>&uid=<%=uid%>" class="link link-primary">购买第二段</a>
                            </td>
                        </tr>
                <%
                    }
                    if (!hasTransferResult) {
                %>
                        <tr>
                            <td colspan="9" class="empty-state">
                                <div class="empty-state-icon">🚄</div>
                                <div class="empty-state-title">暂无换乘车次</div>
                            </td>
                        </tr>
                <%
                    }
                %>
                    </tbody>
                </table>
            </div>
        </div>
    <%
            // 关闭结果集和连接
            rsDirect.close();
            cstmtDirect.close();
            rsTransfer.close();
            cstmtTransfer.close();
            stmt.close();
            conn.close();
        } // 结束else块
    %>
    </div>
</body>
</html>
