<%--
  列国驿轨系统 高速铁路 - 编辑用户信息
--%>
<%@ page language="java" import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<%
    String adminUser = (String)session.getAttribute("admin_username");
    String adminRole = (String)session.getAttribute("admin_role");
    
    if(adminUser == null || (!"user_admin".equals(adminRole) && !"super_admin".equals(adminRole))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String userId = request.getParameter("userid");
    String name = "";
    String gender = "";
    
    if(userId != null) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
            String dbUser = "super_admin".equals(adminRole) ? "root" : "user_admin";
            String dbPass = "super_admin".equals(adminRole) ? "bei060805" : "123456";
            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT name, gender FROM user WHERE id='" + userId + "'");
            
            if(rs.next()) {
                name = rs.getString("name");
                gender = rs.getString("gender");
            }
            conn.close();
        } catch(Exception e) {
            out.println("<div class='alert alert-error'>加载失败：" + e.getMessage() + "</div>");
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>编辑用户 - 列国驿轨系统 高速铁路</title>
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
            <li><a href="user_admin.jsp">首页</a></li>
            <li><a href="user_manage.jsp">用户管理</a></li>
            <li><a href="../index.jsp">返回前台</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">编辑用户信息</h1>
        
        <div class="card fade-in" style="max-width: 500px;">
            <h2 class="card-title">用户ID：<%=userId%></h2>
            <form action="user_manage.jsp" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="userid" value="<%=userId%>">
                
                <div class="form-group">
                    <label class="form-label" for="name">姓名</label>
                    <input type="text" id="name" name="name" class="form-input" value="<%=name%>" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="gender">性别</label>
                    <select id="gender" name="gender" class="form-input" required>
                        <option value="男" <%=("男".equals(gender) ? "selected" : "")%>>男</option>
                        <option value="女" <%=("女".equals(gender) ? "selected" : "")%>>女</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="password">新密码（留空不修改）</label>
                    <input type="password" id="password" name="password" class="form-input" placeholder="留空则不修改密码">
                </div>
                
                <div class="btn-group">
                    <button type="submit" class="btn btn-primary btn-block">保存修改</button>
                    <a href="user_manage.jsp" class="btn btn-secondary btn-block">取消</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>


