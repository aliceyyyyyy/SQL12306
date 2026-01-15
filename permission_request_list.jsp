<%--
  列国驿轨系统 高速铁路 - 权限代理服务 - 我的请求列表
  用户查看自己提交的所有权限提升请求
--%>
<%@ page language="java" import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的请求 - 列国驿轨系统 高速铁路</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .status-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 4px;
            font-weight: 600;
            font-size: 0.875rem;
        }
        .status-pending {
            background: #FFF3CD;
            color: #856404;
        }
        .status-processing {
            background: #D1ECF1;
            color: #0C5460;
        }
        .status-completed {
            background: #D4EDDA;
            color: #155724;
        }
        .status-rejected {
            background: #F8D7DA;
            color: #721C24;
        }
    </style>
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
        if(userid == null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>
    <nav class="navbar">
        <a href="loginsuccess.jsp?message=<%=userid%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="loginsuccess.jsp?message=<%=userid%>">首页</a></li>
            <li><a href="chepiaochaxun.jsp?uid=<%=userid%>">车票查询</a></li>
            <li><a href="tuipiao.jsp">退票</a></li>
            <li><a href="gaipiao.jsp?uid=<%=userid%>">改签</a></li>
            <li><a href="searchrecord.jsp">我的订单</a></li>
            <li><a href="view_trainlist.jsp?uid=<%=userid%>">车次列表</a></li>
            <li><a href="permission_request_list.jsp?uid=<%=userid%>" class="active">权限代理</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
            <div>
                <h1 class="page-title">我的请求</h1>
                <p class="page-subtitle">查看您提交的权限提升请求及处理状态</p>
            </div>
            <a href="permission_request.jsp?uid=<%=userid%>" class="btn btn-primary">+ 提交新请求</a>
        </div>
        
        <%
            // 搜索参数
            String searchKeyword = request.getParameter("search");
            if(searchKeyword == null) searchKeyword = "";
            searchKeyword = searchKeyword.trim();
        %>
        
        <div class="card fade-in" style="max-width: 100%; margin-bottom: 2rem;">
            <form method="GET" action="permission_request_list.jsp" style="display: flex; gap: 1rem; align-items: center; margin-bottom: 1.5rem;">
                <input type="hidden" name="uid" value="<%=userid%>">
                <div class="form-input-wrapper" style="flex: 1; max-width: 400px;">
                    <input type="text" name="search" class="form-input" placeholder="搜索请求编号、标题或类型..." value="<%=searchKeyword%>">
                </div>
                <button type="submit" class="btn btn-primary">搜索</button>
                <% if(!searchKeyword.isEmpty()) { %>
                <a href="permission_request_list.jsp?uid=<%=userid%>" class="btn btn-secondary">清除</a>
                <% } %>
            </form>
        </div>
        
        <div class="card fade-in" style="max-width: 100%;">
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
                    Connection conn = DriverManager.getConnection(url, "root", "bei060805");
                    Statement stmt = conn.createStatement();
                    
                    // 检查表是否存在
                    boolean tableExists = false;
                    try {
                        stmt.executeQuery("SELECT 1 FROM permission_request LIMIT 1");
                        tableExists = true;
                    } catch(SQLException e) {
                        // 表不存在
                    }
                    
                    if(!tableExists) {
            %>
                <div class="alert alert-info">
                    您还没有提交过任何请求。 <a href="permission_request.jsp?uid=<%=userid%>">立即提交请求</a>
                </div>
            <%
                    } else {
                        // 构建搜索条件
                        String whereClause = " WHERE user_id = '" + userid + "'";
                        if(!searchKeyword.isEmpty()) {
                            whereClause += " AND (request_id LIKE '%" + searchKeyword + "%' OR request_title LIKE '%" + searchKeyword + "%' OR request_type LIKE '%" + searchKeyword + "%')";
                        }
                        
                        String sql = "SELECT * FROM permission_request" + whereClause + " ORDER BY create_time DESC";
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        if(!rs.next()) {
            %>
                <div class="alert alert-info">
                    您还没有提交过任何请求。 <a href="permission_request.jsp?uid=<%=userid%>">立即提交请求</a>
                </div>
            <%
                        } else {
            %>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>请求编号</th>
                            <th>请求类型</th>
                            <th>请求标题</th>
                            <th>状态</th>
                            <th>提交时间</th>
                            <th>完成时间</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
            <%
                            do {
                                String requestId = rs.getString("request_id");
                                String requestType = rs.getString("request_type");
                                String requestTitle = rs.getString("request_title");
                                String status = rs.getString("status");
                                Timestamp createTime = rs.getTimestamp("create_time");
                                Timestamp completeTime = rs.getTimestamp("complete_time");
                                
                                String typeName = "";
                                if("user_manage".equals(requestType)) typeName = "用户管理";
                                else if("train_manage".equals(requestType)) typeName = "车次管理";
                                else if("ticket_manage".equals(requestType)) typeName = "车票管理";
                                else if("seat_manage".equals(requestType)) typeName = "座位管理";
                                else typeName = "其他";
                                
                                String statusClass = "status-" + status;
                                String statusText = "";
                                if("pending".equals(status)) statusText = "待处理";
                                else if("processing".equals(status)) statusText = "处理中";
                                else if("completed".equals(status)) statusText = "已完成";
                                else if("rejected".equals(status)) statusText = "已拒绝";
            %>
                        <tr>
                            <td style="font-family: monospace; font-size: 0.875rem;"><%=requestId%></td>
                            <td><%=typeName%></td>
                            <td><%=requestTitle%></td>
                            <td><span class="status-badge <%=statusClass%>"><%=statusText%></span></td>
                            <td><%=createTime != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(createTime) : "-"%></td>
                            <td><%=completeTime != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(completeTime) : "-"%></td>
                            <td>
                                <a href="permission_request_result.jsp?uid=<%=userid%>&request_id=<%=requestId%>" class="btn btn-sm btn-primary">查看详情</a>
                            </td>
                        </tr>
            <%
                            } while(rs.next());
            %>
                    </tbody>
                </table>
            <%
                        }
                    }
                    conn.close();
                } catch(Exception e) {
                    e.printStackTrace();
            %>
                <div class="alert alert-error">
                    加载失败：<%=e.getMessage()%>
                </div>
            <%
                }
            %>
        </div>
    </div>
</body>
</html>

