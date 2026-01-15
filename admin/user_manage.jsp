<%--
  列国驿轨系统 高速铁路 - 用户管理页面
  权限：SELECT和UPDATE user表
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
    
    String action = request.getParameter("action");
    String userId = request.getParameter("userid");
    
    // 处理更新操作
    if("update".equals(action) && userId != null) {
        String name = request.getParameter("name");
        String password = request.getParameter("password");
        String gender = request.getParameter("gender");
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
            String dbUser = "super_admin".equals(adminRole) ? "root" : "user_admin";
            String dbPass = "super_admin".equals(adminRole) ? "bei060805" : "123456";
            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
            Statement stmt = conn.createStatement();
            
            String sql = "UPDATE user SET name='" + name + "', gender='" + gender + "'";
            if(password != null && !password.isEmpty()) {
                sql += ", password='" + password + "'";
            }
            sql += " WHERE id='" + userId + "'";
            
            stmt.executeUpdate(sql);
            conn.close();
            
            response.sendRedirect("user_manage.jsp?success=1");
            return;
        } catch(Exception e) {
            out.println("<div class='alert alert-error'>更新失败：" + e.getMessage() + "</div>");
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户管理 - 列国驿轨系统 高速铁路</title>
    <link rel="stylesheet" href="../css/main.css">
    <style>
        /* 隐藏body背景图片，避免在视频加载前显示 */
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
            /* 确保视频立即加载和显示 */
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
            <li><a href="user_manage.jsp" class="active">用户管理</a></li>
            <li><a href="ticket_query.jsp">订单查询</a></li>
            <li><a href="../index.jsp">返回前台</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">用户管理</h1>
        <p class="page-subtitle">管理用户信息 · 处理用户请求</p>
        
        <%
            if("1".equals(request.getParameter("success"))) {
                out.println("<div class='alert alert-success'>操作成功！</div>");
            }
            
            // 搜索参数
            String searchKeyword = request.getParameter("search");
            if(searchKeyword == null) searchKeyword = "";
            searchKeyword = searchKeyword.trim();
        %>
        
        <div class="card" style="max-width: 100%; margin-bottom: 2rem;">
            <form method="GET" action="user_manage.jsp" style="display: flex; gap: 1rem; align-items: center; margin-bottom: 1.5rem;">
                <div class="form-input-wrapper" style="flex: 1; max-width: 400px;">
                    <input type="text" name="search" class="form-input" placeholder="搜索用户ID或姓名..." value="<%=searchKeyword%>">
                </div>
                <button type="submit" class="btn btn-primary">搜索</button>
                <% if(!searchKeyword.isEmpty()) { %>
                <a href="user_manage.jsp" class="btn btn-secondary">清除</a>
                <% } %>
            </form>
        </div>
        
        <div class="card" style="max-width: 100%;">
            <div class="data-table-wrapper">
                <table class="data-table">
                <thead>
                    <tr>
                        <th>用户ID</th>
                        <th>姓名</th>
                        <th>性别</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        // 分页参数
                        int pageSize = 10;
                        int currentPage = 1;
                        String pageParam = request.getParameter("page");
                        if(pageParam != null && !pageParam.isEmpty()) {
                            try {
                                currentPage = Integer.parseInt(pageParam);
                                if(currentPage < 1) currentPage = 1;
                            } catch(Exception e) {
                                currentPage = 1;
                            }
                        }
                        // 如果有搜索关键词，重置到第一页
                        if(!searchKeyword.isEmpty() && pageParam == null) {
                            currentPage = 1;
                        }
                        int offset = (currentPage - 1) * pageSize;
                        
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
                            String dbUser = "super_admin".equals(adminRole) ? "root" : "user_admin";
                            String dbPass = "super_admin".equals(adminRole) ? "bei060805" : "123456";
                            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
                            
                            // 使用存储过程获取总记录数
                            CallableStatement countCstmt = conn.prepareCall("{call COUNT_USER_MANAGE(?)}");
                            countCstmt.setString(1, searchKeyword.isEmpty() ? null : searchKeyword);
                            ResultSet countRs = countCstmt.executeQuery();
                            int totalRecords = 0;
                            if(countRs.next()) {
                                totalRecords = countRs.getInt("total");
                            }
                            countRs.close();
                            countCstmt.close();
                            
                            // 计算总页数
                            int totalPages = (int)Math.ceil((double)totalRecords / pageSize);
                            if(totalPages == 0) totalPages = 1;
                            if(currentPage > totalPages) currentPage = totalPages;
                            
                            // 使用存储过程进行分页查询
                            CallableStatement cstmt = conn.prepareCall("{call SEARCH_USER_MANAGE(?, ?, ?)}");
                            cstmt.setString(1, searchKeyword.isEmpty() ? null : searchKeyword);
                            cstmt.setInt(2, pageSize);
                            cstmt.setInt(3, offset);
                            ResultSet rs = cstmt.executeQuery();
                            
                            int count = 0;
                            while(rs.next()) {
                                count++;
                                String uid = rs.getString("id");
                                String uname = rs.getString("name");
                                String ugender = rs.getString("gender");
                    %>
                        <tr>
                            <td><%=uid%></td>
                            <td><%=uname%></td>
                            <td><%=ugender%></td>
                            <td>
                                <a href="user_edit.jsp?userid=<%=uid%>" class="link link-primary" style="display: inline; visibility: visible; opacity: 1;">编辑</a>
                            </td>
                        </tr>
                    <%
                            }
                            rs.close();
                            cstmt.close();
                            
                            if(count == 0) {
                                out.println("<tr><td colspan='4' style='text-align: center; padding: 2rem; color: var(--text-muted);'>暂无数据</td></tr>");
                            }
                    %>
                    </tbody>
                </table>
            </div>
            
            <%-- 分页导航 --%>
            <div style="display: flex; justify-content: center; align-items: center; gap: 1rem; margin-top: 2rem; padding: 1rem;">
                <%
                    String pageLinkPrefix = "user_manage.jsp?";
                    if(!searchKeyword.isEmpty()) {
                        pageLinkPrefix += "search=" + java.net.URLEncoder.encode(searchKeyword, "UTF-8") + "&";
                    }
                    
                    if(currentPage > 1) {
                %>
                <a href="<%=pageLinkPrefix%>page=<%=currentPage-1%>" class="btn btn-secondary" style="display: inline-flex; visibility: visible; opacity: 1;">上一页</a>
                <%
                    }
                %>
                <span style="color: var(--text-primary); font-weight: 600;">
                    第 <%=currentPage%> 页 / 共 <%=totalPages%> 页（共 <%=totalRecords%> 条记录）
                    <% if(!searchKeyword.isEmpty()) { %>
                    <span style="color: var(--crimson);">（搜索：<%=searchKeyword%>）</span>
                    <% } %>
                </span>
                <%
                    if(currentPage < totalPages) {
                %>
                <a href="<%=pageLinkPrefix%>page=<%=currentPage+1%>" class="btn btn-secondary" style="display: inline-flex; visibility: visible; opacity: 1;">下一页</a>
                <%
                    }
                    conn.close();
                } catch(Exception e) {
                    out.println("<tr><td colspan='4' class='alert alert-error'>加载失败：" + e.getMessage() + "</td></tr>");
                }
                %>
            </div>
        </div>
    </div>
</body>
</html>


