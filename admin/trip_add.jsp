<%--
  列国驿轨系统 高速铁路 - 添加运行班次（车次管理员）
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
    
    // 处理添加操作
    if("POST".equals(request.getMethod())) {
        String trainnum = request.getParameter("trainnum");
        String time = request.getParameter("time");
        String nowmem = request.getParameter("nowmem");
        String nowprice = request.getParameter("nowprice");
        
        if(trainnum != null && time != null && nowmem != null && nowprice != null) {
            try {
                Class.forName("com.mysql.jdbc.Driver");
                String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
                String dbUser = "super_admin".equals(adminRole) ? "root" : "train_admin";
                String dbPass = "super_admin".equals(adminRole) ? "bei060805" : "123456";
                Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
                Statement stmt = conn.createStatement();
                
                String sql = "INSERT INTO trip (trainnum, time, nowmem, nowprice) VALUES " +
                            "('" + trainnum + "', '" + time + "', " + nowmem + ", " + nowprice + ")";
                stmt.executeUpdate(sql);
                conn.close();
                
                response.sendRedirect("trip_manage.jsp?success=1");
                return;
            } catch(Exception e) {
                out.println("<div class='alert alert-error'>添加失败：" + e.getMessage() + "</div>");
            }
        }
    }
    
    // 获取所有车次列表
    java.util.List<String> trainList = new java.util.ArrayList<>();
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
        String dbUser = "super_admin".equals(adminRole) ? "root" : "train_admin";
        String dbPass = "super_admin".equals(adminRole) ? "bei060805" : "123456";
        Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT trainnum FROM train ORDER BY trainnum");
        while(rs.next()) {
            trainList.add(rs.getString("trainnum"));
        }
        conn.close();
    } catch(Exception e) {
        // 忽略错误
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>添加运行班次 - 列国驿轨系统 高速铁路</title>
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
            <li><a href="trip_manage.jsp">运行班次管理</a></li>
            <li><a href="ticket_manage.jsp">车票管理</a></li>
            <li><a href="../index.jsp">返回前台</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">添加运行班次</h1>
        <p class="page-subtitle">填写运行班次信息</p>
        
        <div class="card" style="max-width: 600px;">
            <form method="POST" action="trip_add.jsp">
                <div class="form-group">
                    <label for="trainnum">车次 *</label>
                    <select id="trainnum" name="trainnum" required>
                        <option value="">请选择车次</option>
                        <% for(String tn : trainList) { %>
                            <option value="<%=tn%>"><%=tn%></option>
                        <% } %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="time">发车时间 *</label>
                    <input type="datetime-local" id="time" name="time" required>
                </div>
                
                <div class="form-group">
                    <label for="nowmem">当前余票数 *</label>
                    <input type="number" id="nowmem" name="nowmem" required 
                           min="0" placeholder="例如：200">
                </div>
                
                <div class="form-group">
                    <label for="nowprice">当前价格（元） *</label>
                    <input type="number" id="nowprice" name="nowprice" required 
                           min="0" step="0.01" placeholder="例如：300.00">
                </div>
                
                <div class="form-group">
                    <button type="submit" class="btn btn-primary">添加运行班次</button>
                    <a href="trip_manage.jsp" class="btn btn-secondary">取消</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>

