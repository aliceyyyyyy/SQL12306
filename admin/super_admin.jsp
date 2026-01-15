<%--
  列国驿轨系统 高速铁路 - 数据库维护人员主页面（超级用户）
  权限：所有权限
--%>
<%@ page language="java" import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<%
    String adminUser = (String)session.getAttribute("admin_username");
    String adminRole = (String)session.getAttribute("admin_role");
    
    if(adminUser == null || !"super_admin".equals(adminRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 数据库维护</title>
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
        <a href="super_admin.jsp" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="super_admin.jsp" class="active">首页</a></li>
            <li><a href="db_backup.jsp">数据库备份</a></li>
            <li><a href="db_restore.jsp">数据库恢复</a></li>
            <li><a href="user_manage.jsp">用户管理</a></li>
            <li><a href="train_manage.jsp">车次管理</a></li>
            <li><a href="permission_requests.jsp">权限代理</a></li>
            <li><a href="../index.jsp">返回前台</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">数据库维护控制台</h1>
        <p class="page-subtitle">欢迎，<%=adminUser%> · 数据库维护人员（超级用户）</p>
        
        <div class="alert alert-info" style="margin: 2rem 0;">
            <strong>超级用户权限：</strong> 您拥有系统的所有权限，可以进行数据库的完整维护和管理操作。
        </div>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2rem; margin: 2rem 0;">
            <div class="card">
                <h3 style="color: var(--crimson); margin-bottom: 1rem;">数据库操作</h3>
                <div style="display: flex; flex-direction: column; gap: 1rem;">
                    <a href="db_backup.jsp" class="btn btn-primary">数据库备份</a>
                    <a href="db_restore.jsp" class="btn btn-secondary">数据库恢复</a>
                    <a href="db_optimize.jsp" class="btn btn-secondary">数据库优化</a>
                </div>
            </div>
            
            <div class="card">
                <h3 style="color: var(--crimson); margin-bottom: 1rem;">数据管理</h3>
                <div style="display: flex; flex-direction: column; gap: 1rem;">
                    <a href="user_manage.jsp" class="btn btn-primary">用户管理</a>
                    <a href="train_manage.jsp" class="btn btn-secondary">车次管理</a>
                    <a href="ticket_manage.jsp" class="btn btn-secondary">车票管理</a>
                    <a href="permission_requests.jsp" class="btn btn-secondary">权限代理服务</a>
                </div>
            </div>
            
            <div class="card">
                <h3 style="color: var(--crimson); margin-bottom: 1rem;">系统统计</h3>
                <%
                    try {
                        Class.forName("com.mysql.jdbc.Driver");
                        String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
                        Connection conn = DriverManager.getConnection(url, "root", "bei060805");
                        Statement stmt = conn.createStatement();
                        
                        // 统计所有表的数据
                        ResultSet rs1 = stmt.executeQuery("SELECT COUNT(*) as count FROM user");
                        int userCount = 0;
                        if(rs1.next()) userCount = rs1.getInt("count");
                        
                        ResultSet rs2 = stmt.executeQuery("SELECT COUNT(*) as count FROM train");
                        int trainCount = 0;
                        if(rs2.next()) trainCount = rs2.getInt("count");
                        
                        ResultSet rs3 = stmt.executeQuery("SELECT COUNT(*) as count FROM ticket");
                        int ticketCount = 0;
                        if(rs3.next()) ticketCount = rs3.getInt("count");
                        
                        ResultSet rs4 = stmt.executeQuery("SELECT COUNT(*) as count FROM seat");
                        int seatCount = 0;
                        if(rs4.next()) seatCount = rs4.getInt("count");
                        
                        conn.close();
                %>
                    <div style="font-size: 1.25rem; color: var(--crimson); font-weight: 700; margin: 0.5rem 0;">
                        用户：<%=userCount%>
                    </div>
                    <div style="font-size: 1.25rem; color: var(--crimson); font-weight: 700; margin: 0.5rem 0;">
                        车次：<%=trainCount%>
                    </div>
                    <div style="font-size: 1.25rem; color: var(--crimson); font-weight: 700; margin: 0.5rem 0;">
                        车票：<%=ticketCount%>
                    </div>
                    <div style="font-size: 1.25rem; color: var(--crimson); font-weight: 700; margin: 0.5rem 0;">
                        座位：<%=seatCount%>
                    </div>
                <%
                    } catch(Exception e) {
                        out.println("<div class='alert alert-error'>统计信息加载失败：" + e.getMessage() + "</div>");
                    }
                %>
            </div>
        </div>
    </div>
</body>
</html>


