<%--
  列国驿轨系统 高速铁路 - 座位管理（车次管理员）
--%>
<%@ page language="java" import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<%
    String adminUser = (String)session.getAttribute("admin_username");
    String adminRole = (String)session.getAttribute("admin_role");
    
    if(adminUser == null || (!"train_admin".equals(adminRole) && !"super_admin".equals(adminRole))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>座位管理 - 列国驿轨系统 高速铁路</title>
    <link rel="stylesheet" href="../css/main.css">
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
        }
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
        
        /* 白色卡片内的文字保持红色 */
        .card .card-title,
        .card h3 {
            color: var(--crimson) !important;
        }
    </style>
</head>
<body>
    <video class="video-background" autoplay muted loop playsinline preload="auto">
        <source src="../HEVC 王者荣耀 王者冰刃.mp4" type="video/mp4">
    </video>
    <nav class="navbar">
        <a href="train_admin.jsp" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="train_admin.jsp">首页</a></li>
            <li><a href="train_manage.jsp">车次管理</a></li>
            <li><a href="trip_manage.jsp" class="active">运行班次管理</a></li>
            <li><a href="ticket_manage.jsp">车票管理</a></li>
            <li><a href="../index.jsp">返回前台</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">运行班次管理</h1>
        <p class="page-subtitle">查看和管理车次运行信息及余票情况</p>
        
        <div class="card" style="max-width: 100%;">
            <div class="data-table-wrapper">
                <table class="data-table">
                <thead>
                    <tr>
                        <th>车次</th>
                        <th>发车时间</th>
                        <th>当前余票</th>
                        <th>总座位数</th>
                        <th>当前价格（元）</th>
                        <th>上座率</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
                            String dbUser = "super_admin".equals(adminRole) ? "root" : "train_admin";
                            String dbPass = "super_admin".equals(adminRole) ? "bei060805" : "123456";
                            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
                            Statement stmt = conn.createStatement();
                            // 通过trip表查询，join train表获取总座位数
                            String sql = "SELECT t.trainnum, t.time, t.nowmem, t.nowprice, tr.maxmem " +
                                        "FROM trip t JOIN train tr ON t.trainnum = tr.trainnum " +
                                        "ORDER BY t.time DESC LIMIT 100";
                            ResultSet rs = stmt.executeQuery(sql);
                            
                            while(rs.next()) {
                                int nowmem = rs.getInt("nowmem");
                                int maxmem = rs.getInt("maxmem");
                                double occupancy = maxmem > 0 ? (double)(maxmem - nowmem) / maxmem * 100 : 0;
                                String occupancyColor = occupancy > 80 ? "var(--danger)" : (occupancy > 50 ? "var(--warning)" : "var(--success)");
                    %>
                        <tr>
                            <td><strong><%=rs.getString("trainnum")%></strong></td>
                            <td><%=rs.getString("time")%></td>
                            <td style="color: #E8C547; font-weight: 600;"><%=nowmem%></td>
                            <td><%=maxmem%></td>
                            <td><strong style="color: var(--accent-color);">¥<%=rs.getString("nowprice")%></strong></td>
                            <td style="color: <%=occupancyColor%>; font-weight: 600;"><%=String.format("%.1f", occupancy)%>%</td>
                        </tr>
                    <%
                            }
                            conn.close();
                        } catch(Exception e) {
                            out.println("<tr><td colspan='6' class='alert alert-error'>加载失败：" + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>


