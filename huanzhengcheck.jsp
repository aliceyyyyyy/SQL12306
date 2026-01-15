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
    <title>列国驿轨系统 高速铁路 - 换乘查询结果</title>
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
    <nav class="navbar">
        <%
            String uid = request.getParameter("uid");
            String homeLink = uid != null ? "loginsuccess.jsp?message=" + uid : "loginsuccess.jsp";
        %>
        <a href="<%=homeLink%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="<%=homeLink%>">首页</a></li>
            <li><a href="tuipiao.jsp">退票</a></li>
            <li><a href="searchrecord.jsp">我的订单</a></li>
            <li><a href="gaipiao.jsp?uid=<%=uid%>">改签</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">换乘查询结果</h1>
        <p class="page-subtitle">为您找到以下换乘车次组合</p>
    <%
        request.setCharacterEncoding("utf-8");
        String origin=request.getParameter("origin");
        String destination=request.getParameter("destination");
        String year=request.getParameter("year");
        String month=request.getParameter("month");
        String day=request.getParameter("day");
        String uid=request.getParameter("uid");
        // 格式化日期，确保月份和日期是两位数
        String monthFormatted = (month != null && month.length() == 1) ? "0" + month : (month != null ? month : "");
        String dayFormatted = (day != null && day.length() == 1) ? "0" + day : (day != null ? day : "");
        String date = year + "-" + monthFormatted + "-" + dayFormatted;
        
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
        // 调用换乘查询存储过程
        CallableStatement cstmt = conn.prepareCall( "{call SEARCH_TRANSFER(?,?,?)}" );
        cstmt.setString( 1 ,origin);
        cstmt.setString( 2 ,destination);
        cstmt.setString( 3 ,date);
        ResultSet rs = cstmt.executeQuery();
        
        // 为了获取第一段和第二段的单独价格，需要再查询trip表
        Statement stmt = conn.createStatement();

    %>
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
                boolean hasResult = false;
                while (rs.next()) {
                    hasResult = true;
                    String firstTrain=rs.getString(1);
                    String ori=rs.getString(2);
                    String transferStation=rs.getString(3);
                    String firstDepart=rs.getString(4);
                    String secondTrain=rs.getString(5);
                    String des=rs.getString(6);
                    String secondDepart=rs.getString(7);
                    String totalPrice=rs.getString(8);
                    
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
                if (!hasResult) {
            %>
                    <tr>
                        <td colspan="9" class="empty-state">
                            <div class="empty-state-icon">🚄</div>
                            <div class="empty-state-title">暂无换乘车次</div>
                            <p>请尝试调整查询条件或选择直达车次</p>
                        </td>
                    </tr>
            <%
                }
            %>
                </tbody>
            </table>
        </div>
    <%
        rs.close();
        cstmt.close();
        stmt.close();
        conn.close();
    %>
    </div>
</body>
</html>

