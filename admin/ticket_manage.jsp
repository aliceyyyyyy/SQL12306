<%--
  列国驿轨系统 高速铁路 - 车票管理（车次管理员）
  权限：seat表和ticket表的全部权限
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
    
    String action = request.getParameter("action");
    String ticketNum = request.getParameter("ticketnum");
    
    // 处理删除操作
    if("delete".equals(action) && ticketNum != null) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
            String dbUser = "super_admin".equals(adminRole) ? "root" : "train_admin";
            String dbPass = "super_admin".equals(adminRole) ? "bei060805" : "123456";
            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
            Statement stmt = conn.createStatement();
            stmt.executeUpdate("DELETE FROM ticket WHERE ticketnum='" + ticketNum + "'");
            conn.close();
            
            response.sendRedirect("ticket_manage.jsp?success=1");
            return;
        } catch(Exception e) {
            out.println("<div class='alert alert-error'>删除失败：" + e.getMessage() + "</div>");
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>车票管理 - 列国驿轨系统 高速铁路</title>
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
            <li><a href="ticket_manage.jsp" class="active">车票管理</a></li>
            <li><a href="../index.jsp">返回前台</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">车票管理</h1>
        <p class="page-subtitle">管理所有车票信息</p>
        
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
            <form method="GET" action="ticket_manage.jsp" style="display: flex; gap: 1rem; align-items: center; margin-bottom: 1.5rem;">
                <div class="form-input-wrapper" style="flex: 1; max-width: 400px;">
                    <input type="text" name="search" class="form-input" placeholder="搜索车票编号、用户ID、车次或座位号..." value="<%=searchKeyword%>">
                </div>
                <button type="submit" class="btn btn-primary">搜索</button>
                <% if(!searchKeyword.isEmpty()) { %>
                <a href="ticket_manage.jsp" class="btn btn-secondary">清除</a>
                <% } %>
            </form>
        </div>
        
        <div class="card" style="max-width: 100%;">
            <div class="data-table-wrapper">
                <table class="data-table">
                <thead>
                    <tr>
                        <th>车票编号</th>
                        <th>用户ID</th>
                        <th>座位号</th>
                        <th>车次</th>
                        <th>发车时间</th>
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
                            String dbUser = "super_admin".equals(adminRole) ? "root" : "train_admin";
                            String dbPass = "super_admin".equals(adminRole) ? "bei060805" : "123456";
                            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
                            Statement stmt = conn.createStatement();
                            
                            // 构建搜索条件
                            String whereClause = "";
                            if(!searchKeyword.isEmpty()) {
                                whereClause = " WHERE ticketnum LIKE '%" + searchKeyword + "%' OR id LIKE '%" + searchKeyword + "%' OR trainnum LIKE '%" + searchKeyword + "%' OR seatnum LIKE '%" + searchKeyword + "%'";
                            }
                            
                            // 获取总记录数
                            String countSql = "SELECT COUNT(*) as total FROM ticket" + whereClause;
                            ResultSet countRs = stmt.executeQuery(countSql);
                            int totalRecords = 0;
                            if(countRs.next()) {
                                totalRecords = countRs.getInt("total");
                            }
                            countRs.close();
                            
                            // 计算总页数
                            int totalPages = (int)Math.ceil((double)totalRecords / pageSize);
                            if(totalPages == 0) totalPages = 1;
                            if(currentPage > totalPages) currentPage = totalPages;
                            
                            // 分页查询
                            String sql = "SELECT ticketnum, id, seatnum, trainnum, time FROM ticket" + whereClause + " ORDER BY time DESC LIMIT " + pageSize + " OFFSET " + offset;
                            ResultSet rs = stmt.executeQuery(sql);
                            
                            int count = 0;
                            while(rs.next()) {
                                count++;
                                String tnum = rs.getString("ticketnum");
                                String timeStr = rs.getString("time");
                                // 格式化时间
                                if(timeStr != null && timeStr.length() > 16) {
                                    timeStr = timeStr.substring(0, 16);
                                }
                    %>
                        <tr>
                            <td><%=tnum%></td>
                            <td><%=rs.getString("id")%></td>
                            <td><%=rs.getString("seatnum")%></td>
                            <td><strong><%=rs.getString("trainnum")%></strong></td>
                            <td><%=timeStr%></td>
                            <td>
                                <a href="ticket_manage.jsp?action=delete&ticketnum=<%=tnum%>" 
                                   onclick="return confirm('确定要删除这张车票吗？')" 
                                   class="link" style="color: var(--danger); display: inline; visibility: visible; opacity: 1;">删除</a>
                            </td>
                        </tr>
                    <%
                            }
                            rs.close();
                            
                            if(count == 0) {
                                out.println("<tr><td colspan='6' style='text-align: center; padding: 2rem; color: var(--text-muted);'>暂无数据</td></tr>");
                            }
                    %>
                    </tbody>
                </table>
            </div>
            
            <%-- 分页导航 --%>
            <div style="display: flex; justify-content: center; align-items: center; gap: 1rem; margin-top: 2rem; padding: 1rem;">
                <%
                    String pageLinkPrefix = "ticket_manage.jsp?";
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
                    out.println("<tr><td colspan='6' class='alert alert-error'>加载失败：" + e.getMessage() + "</td></tr>");
                }
                %>
            </div>
        </div>
    </div>
</body>
</html>


