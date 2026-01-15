<%--
  列国驿轨系统 高速铁路 - 普通用户管理员主页面
  权限：SELECT所有表，UPDATE user表
--%>
<%@ page language="java" import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<%
    String adminUser = (String)session.getAttribute("admin_username");
    String adminRole = (String)session.getAttribute("admin_role");
    
    if(adminUser == null || !"user_admin".equals(adminRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 用户管理员</title>
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
        <a href="user_admin.jsp" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="user_admin.jsp" class="active">首页</a></li>
            <li><a href="user_manage.jsp">用户管理</a></li>
            <li><a href="ticket_query.jsp">订单查询</a></li>
            <li><a href="permission_requests.jsp">权限代理</a></li>
            <li><a href="../index.jsp">返回前台</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">用户管理员控制台</h1>
        <p class="page-subtitle">欢迎，<%=adminUser%> · 普通用户管理员</p>
        
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2rem; margin: 2rem 0;">
            <div class="card">
                <h3 style="color: var(--crimson); margin-bottom: 1rem;">权限说明</h3>
                <ul style="list-style: none; padding: 0;">
                    <li style="padding: 0.5rem 0; border-bottom: 1px solid var(--border);">✓ 查看所有用户信息</li>
                    <li style="padding: 0.5rem 0; border-bottom: 1px solid var(--border);">✓ 修改用户信息</li>
                    <li style="padding: 0.5rem 0; border-bottom: 1px solid var(--border);">✓ 查看所有订单</li>
                    <li style="padding: 0.5rem 0; border-bottom: 1px solid var(--border);">✓ 查看车次信息</li>
                    <li style="padding: 0.5rem 0;">✓ 处理用户请求</li>
                </ul>
            </div>
            
            <div class="card">
                <h3 style="color: var(--crimson); margin-bottom: 1rem;">快速操作</h3>
                <div style="display: flex; flex-direction: column; gap: 1rem;">
                    <a href="user_manage.jsp" class="btn btn-primary">用户管理</a>
                    <a href="ticket_query.jsp" class="btn btn-secondary">订单查询</a>
                    <a href="permission_requests.jsp" class="btn btn-secondary">权限代理服务</a>
                </div>
            </div>
            
            <div class="card">
                <h3 style="color: var(--crimson); margin-bottom: 1rem;">系统统计</h3>
                <%
                    try {
                        Class.forName("com.mysql.jdbc.Driver");
                        String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
                        Connection conn = DriverManager.getConnection(url, "user_admin", "123456");
                        Statement stmt = conn.createStatement();
                        
                        // 统计用户数量
                        ResultSet rs1 = stmt.executeQuery("SELECT COUNT(*) as count FROM user");
                        int userCount = 0;
                        if(rs1.next()) userCount = rs1.getInt("count");
                        
                        // 统计订单数量
                        ResultSet rs2 = stmt.executeQuery("SELECT COUNT(*) as count FROM ticket");
                        int ticketCount = 0;
                        if(rs2.next()) ticketCount = rs2.getInt("count");
                        
                        conn.close();
                %>
                    <div style="font-size: 2rem; color: var(--crimson); font-weight: 700; margin: 1rem 0;">
                        用户总数：<%=userCount%>
                    </div>
                    <div style="font-size: 2rem; color: var(--crimson); font-weight: 700; margin: 1rem 0;">
                        订单总数：<%=ticketCount%>
                    </div>
                <%
                    } catch(Exception e) {
                        out.println("<div class='alert alert-error'>统计信息加载失败</div>");
                    }
                %>
            </div>
        </div>
    </div>
</body>
</html>


