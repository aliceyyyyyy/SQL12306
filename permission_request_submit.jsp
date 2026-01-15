<%--
  列国驿轨系统 高速铁路 - 权限代理服务 - 请求提交处理
  接收用户提交的权限提升请求并保存到数据库
--%>
<%@ page language="java" import="java.sql.*, java.util.UUID, java.text.SimpleDateFormat, java.util.Date" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>提交请求 - 列国驿轨系统 高速铁路</title>
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
    </style>
</head>
<body>
    <video class="video-background" autoplay muted loop playsinline preload="auto">
        <source src="Star_Rail_Wallpaper.mp4" type="video/mp4">
    </video>
    <%
        String userid = request.getParameter("uid");
        String requestType = request.getParameter("request_type");
        String requestTitle = request.getParameter("request_title");
        String requestContent = request.getParameter("request_content");
        String requestParams = request.getParameter("request_params");
        
        if(userid == null || requestType == null || requestTitle == null || requestTitle.trim().isEmpty()) {
            response.sendRedirect("permission_request.jsp?uid=" + (userid != null ? userid : ""));
            return;
        }
        
        // 生成请求ID
        String requestId = "REQ" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        
        // 根据请求类型确定需要的管理员角色
        String adminRole = "";
        if("user_manage".equals(requestType)) {
            adminRole = "user_admin";
        } else if("train_manage".equals(requestType)) {
            adminRole = "train_admin";
        } else if("ticket_manage".equals(requestType) || "seat_manage".equals(requestType)) {
            adminRole = "train_admin";
        } else {
            adminRole = "user_admin"; // 默认分配给用户管理员
        }
        
        try {
            // 先确保表存在（如果不存在则创建）
            Class.forName("com.mysql.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
            Connection conn = DriverManager.getConnection(url, "root", "bei060805");
            Statement stmt = conn.createStatement();
            
            // 检查表是否存在
            try {
                stmt.executeQuery("SELECT 1 FROM permission_request LIMIT 1");
            } catch(SQLException e) {
                // 表不存在，创建表（建议使用 init_permission_request_table.sql 手动创建以获得完整结构）
                String createTableSQL = 
                    "CREATE TABLE IF NOT EXISTS permission_request (" +
                    "request_id VARCHAR(50) PRIMARY KEY, " +
                    "user_id VARCHAR(50) NOT NULL, " +
                    "request_type VARCHAR(50) NOT NULL, " +
                    "request_title VARCHAR(200) NOT NULL, " +
                    "request_content TEXT, " +
                    "request_params TEXT, " +
                    "admin_role VARCHAR(50), " +
                    "assigned_admin VARCHAR(50), " +
                    "status VARCHAR(20) DEFAULT 'pending', " +
                    "create_time DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                    "assign_time DATETIME, " +
                    "complete_time DATETIME, " +
                    "result_content TEXT, " +
                    "result_data TEXT, " +
                    "INDEX idx_user_id (user_id), " +
                    "INDEX idx_status (status), " +
                    "INDEX idx_admin_role (admin_role), " +
                    "INDEX idx_create_time (create_time)" +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
                stmt.executeUpdate(createTableSQL);
            }
            
            // 插入请求记录
            String sql = "INSERT INTO permission_request (request_id, user_id, request_type, request_title, request_content, request_params, admin_role, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, requestId);
            pstmt.setString(2, userid);
            pstmt.setString(3, requestType);
            pstmt.setString(4, requestTitle);
            pstmt.setString(5, requestContent != null ? requestContent : "");
            pstmt.setString(6, requestParams != null ? requestParams : "");
            pstmt.setString(7, adminRole);
            pstmt.executeUpdate();
            
            conn.close();
            
            // 重定向到成功页面
            response.sendRedirect("permission_request_success.jsp?uid=" + userid + "&request_id=" + requestId);
            
        } catch(Exception e) {
            e.printStackTrace();
%>
    <nav class="navbar">
        <a href="loginsuccess.jsp?message=<%=userid%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="loginsuccess.jsp?message=<%=userid%>">首页</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <div class="card fade-in">
            <div class="alert alert-error">
                <strong>提交失败</strong> 系统错误：<%=e.getMessage()%>
            </div>
            <div class="text-center mt-3">
                <a href="permission_request.jsp?uid=<%=userid%>" class="btn btn-primary">返回重试</a>
                <a href="loginsuccess.jsp?message=<%=userid%>" class="btn btn-secondary">返回首页</a>
            </div>
        </div>
    </div>
<%
        }
    %>
</body>
</html>

