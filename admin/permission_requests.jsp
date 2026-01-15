<%--
  列国驿轨系统 高速铁路 - 权限代理服务 - 管理员请求管理页面
  管理员查看和处理用户提交的权限提升请求
--%>
<%@ page language="java" import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<%
    String adminUser = (String)session.getAttribute("admin_username");
    String adminRole = (String)session.getAttribute("admin_role");
    
    if(adminUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // 根据管理员角色确定可以处理的请求类型（权限分层）
    // user_admin: 只能处理用户管理相关请求（user_manage, other）
    // train_admin: 只能处理车次、车票、座位管理相关请求（train_manage, ticket_manage, seat_manage）
    // super_admin: 可以处理所有请求
    String roleFilter = "";
    if("user_admin".equals(adminRole)) {
        // 用户管理员只能处理用户管理类型的请求
        roleFilter = "admin_role = 'user_admin'";
    } else if("train_admin".equals(adminRole)) {
        // 车次管理员只能处理车次、车票、座位管理类型的请求
        roleFilter = "admin_role = 'train_admin'";
    } else if("super_admin".equals(adminRole)) {
        roleFilter = "1=1"; // 超级管理员可以处理所有请求
    } else {
        response.sendRedirect("login.jsp");
        return;
    }
    
    System.out.println("权限代理查询 - 管理员角色: " + adminRole + ", 过滤条件: " + roleFilter);
    
    String filterStatus = request.getParameter("status");
    String whereClause = roleFilter;
    if(filterStatus != null && !filterStatus.isEmpty() && !"all".equals(filterStatus)) {
        whereClause += " AND status = '" + filterStatus + "'";
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>权限代理服务 - 列国驿轨系统 高速铁路</title>
    <link rel="stylesheet" href="../css/main.css">
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
        .filter-tabs {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
        }
        .filter-tab {
            padding: 0.5rem 1rem;
            border: 2px solid var(--border);
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(10px);
            border-radius: 4px;
            text-decoration: none;
            color: var(--text-primary);
            transition: var(--transition);
        }
        .filter-tab:hover, .filter-tab.active {
            border-color: #E8C547;
            background: var(--crimson);
            color: white;
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
        
        .card-title {
            color: #E8C547 !important;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3) !important;
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
        <a href="<%="super_admin".equals(adminRole) ? "super_admin.jsp" : ("train_admin".equals(adminRole) ? "train_admin.jsp" : "user_admin.jsp")%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="<%="super_admin".equals(adminRole) ? "super_admin.jsp" : ("train_admin".equals(adminRole) ? "train_admin.jsp" : "user_admin.jsp")%>">首页</a></li>
            <% if("user_admin".equals(adminRole) || "super_admin".equals(adminRole)) { %>
            <li><a href="user_manage.jsp">用户管理</a></li>
            <% } %>
            <% if("train_admin".equals(adminRole) || "super_admin".equals(adminRole)) { %>
            <li><a href="train_manage.jsp">车次管理</a></li>
            <li><a href="ticket_manage.jsp">车票管理</a></li>
            <% } %>
            <li><a href="permission_requests.jsp" class="active">权限代理</a></li>
            <li><a href="../index.jsp">返回前台</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">权限代理服务</h1>
        <p class="page-subtitle">
            <% if("user_admin".equals(adminRole)) { %>
                处理用户管理相关请求（用户信息、密码重置等）
            <% } else if("train_admin".equals(adminRole)) { %>
                处理车次、车票、座位管理相关请求
            <% } else { %>
                处理用户提交的权限提升请求
            <% } %>
        </p>
        
        <div class="filter-tabs">
            <a href="permission_requests.jsp?status=all" class="filter-tab <%=filterStatus == null || "all".equals(filterStatus) ? "active" : ""%>">全部</a>
            <a href="permission_requests.jsp?status=pending" class="filter-tab <%="pending".equals(filterStatus) ? "active" : ""%>">待处理</a>
            <a href="permission_requests.jsp?status=processing" class="filter-tab <%="processing".equals(filterStatus) ? "active" : ""%>">处理中</a>
            <a href="permission_requests.jsp?status=completed" class="filter-tab <%="completed".equals(filterStatus) ? "active" : ""%>">已完成</a>
            <a href="permission_requests.jsp?status=rejected" class="filter-tab <%="rejected".equals(filterStatus) ? "active" : ""%>">已拒绝</a>
        </div>
        
        <div class="card fade-in" style="max-width: 100%;">
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
                    // 统一使用 root 用户连接，因为 permission_request 表是系统级别的，需要完整权限
                    String dbUser = "root";
                    String dbPass = "bei060805";
                    Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
                    Statement stmt = conn.createStatement();
                    
                    System.out.println("管理员查看权限申请 - 角色: " + adminRole + ", 过滤条件: " + whereClause);
                    
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
                    暂无请求数据
                </div>
            <%
                    } else {
                        String sql = "SELECT * FROM permission_request WHERE " + whereClause + " ORDER BY create_time DESC";
                        System.out.println("查询SQL: " + sql);
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        int requestCount = 0;
                        if(!rs.next()) {
            %>
                <div class="alert alert-info">
                    暂无符合条件的请求
                </div>
            <%
                        } else {
            %>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>请求编号</th>
                            <th>用户ID</th>
                            <th>请求类型</th>
                            <th>请求标题</th>
                            <th>状态</th>
                            <th>提交时间</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
            <%
                            do {
                                requestCount++;
                                String requestId = rs.getString("request_id");
                                String userId = rs.getString("user_id");
                                String requestType = rs.getString("request_type");
                                String requestTitle = rs.getString("request_title");
                                String status = rs.getString("status");
                                Timestamp createTime = rs.getTimestamp("create_time");
                                
                                System.out.println("请求 " + requestCount + ": ID=" + requestId + ", 用户=" + userId + ", 类型=" + requestType + ", 状态=" + status);
                                
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
                            <td><%=userId%></td>
                            <td><%=typeName%></td>
                            <td><%=requestTitle%></td>
                            <td><span class="status-badge <%=statusClass%>"><%=statusText%></span></td>
                            <td><%=createTime != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(createTime) : "-"%></td>
                            <td>
                                <a href="permission_process.jsp?request_id=<%=requestId%>" class="btn btn-sm btn-primary">处理</a>
                            </td>
                        </tr>
            <%
                            } while(rs.next());
                            
                            System.out.println("查询到 " + requestCount + " 条权限申请记录");
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

