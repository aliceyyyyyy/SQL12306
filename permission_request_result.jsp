<%--
  列国驿轨系统 高速铁路 - 权限代理服务 - 请求详情和结果
  用户查看单个权限提升请求的详细信息和处理结果
--%>
<%@ page language="java" import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>请求详情 - 列国驿轨系统 高速铁路</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .status-badge {
            display: inline-block;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            font-weight: 600;
            font-size: 1rem;
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
        .detail-section {
            margin-bottom: 2rem;
            padding: 1.5rem;
            background: var(--bg-secondary);
            border-radius: 8px;
        }
        .detail-label {
            font-weight: 600;
            color: var(--text-secondary);
            margin-bottom: 0.5rem;
        }
        .detail-value {
            color: var(--text-primary);
            line-height: 1.8;
        }
        .result-box {
            padding: 1.5rem;
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(10px);
            border-left: 4px solid var(--crimson);
            border-radius: 4px;
            margin-top: 1rem;
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
        String requestId = request.getParameter("request_id");
        if(userid == null || requestId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
            Connection conn = DriverManager.getConnection(url, "root", "bei060805");
            Statement stmt = conn.createStatement();
            
            String sql = "SELECT * FROM permission_request WHERE request_id = '" + requestId + "' AND user_id = '" + userid + "'";
            ResultSet rs = stmt.executeQuery(sql);
            
            if(!rs.next()) {
                conn.close();
                response.sendRedirect("permission_request_list.jsp?uid=" + userid);
                return;
            }
            
            String requestType = rs.getString("request_type");
            String requestTitle = rs.getString("request_title");
            String requestContent = rs.getString("request_content");
            String requestParams = rs.getString("request_params");
            String adminRole = rs.getString("admin_role");
            String assignedAdmin = rs.getString("assigned_admin");
            String status = rs.getString("status");
            Timestamp createTime = rs.getTimestamp("create_time");
            Timestamp assignTime = rs.getTimestamp("assign_time");
            Timestamp completeTime = rs.getTimestamp("complete_time");
            String resultContent = rs.getString("result_content");
            String resultData = rs.getString("result_data");
            
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
            
            conn.close();
    %>
    <nav class="navbar">
        <a href="loginsuccess.jsp?message=<%=userid%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="loginsuccess.jsp?message=<%=userid%>">首页</a></li>
            <li><a href="tuipiao.jsp">退票</a></li>
            <li><a href="searchrecord.jsp">我的订单</a></li>
            <li><a href="permission_request_list.jsp?uid=<%=userid%>">我的请求</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
            <div>
                <h1 class="page-title">请求详情</h1>
                <p class="page-subtitle">请求编号：<%=requestId%></p>
            </div>
            <span class="status-badge <%=statusClass%>"><%=statusText%></span>
        </div>
        
        <div class="card fade-in">
            <div class="detail-section">
                <h3 style="color: #E8C547; margin-bottom: 1rem;">基本信息</h3>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem;">
                    <div>
                        <div class="detail-label">请求类型</div>
                        <div class="detail-value"><%=typeName%></div>
                    </div>
                    <div>
                        <div class="detail-label">请求标题</div>
                        <div class="detail-value"><%=requestTitle%></div>
                    </div>
                    <div>
                        <div class="detail-label">提交时间</div>
                        <div class="detail-value"><%=createTime != null ? new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(createTime) : "-"%></div>
                    </div>
                    <div>
                        <div class="detail-label">分配管理员角色</div>
                        <div class="detail-value"><%=adminRole != null ? adminRole : "待分配"%></div>
                    </div>
                    <% if(assignedAdmin != null && !assignedAdmin.isEmpty()) { %>
                    <div>
                        <div class="detail-label">处理管理员</div>
                        <div class="detail-value"><%=assignedAdmin%></div>
                    </div>
                    <% } %>
                    <% if(assignTime != null) { %>
                    <div>
                        <div class="detail-label">分配时间</div>
                        <div class="detail-value"><%=new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(assignTime)%></div>
                    </div>
                    <% } %>
                    <% if(completeTime != null) { %>
                    <div>
                        <div class="detail-label">完成时间</div>
                        <div class="detail-value"><%=new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(completeTime)%></div>
                    </div>
                    <% } %>
                </div>
            </div>
            
            <% if(requestContent != null && !requestContent.trim().isEmpty()) { %>
            <div class="detail-section">
                <div class="detail-label">详细说明</div>
                <div class="detail-value" style="white-space: pre-wrap;"><%=requestContent%></div>
            </div>
            <% } %>
            
            <% if(requestParams != null && !requestParams.trim().isEmpty()) { %>
            <div class="detail-section">
                <div class="detail-label">请求参数</div>
                <div class="detail-value" style="font-family: monospace; background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(10px); padding: 1rem; border-radius: 4px; white-space: pre-wrap;"><%=requestParams%></div>
            </div>
            <% } %>
            
            <% if(resultContent != null && !resultContent.trim().isEmpty()) { %>
            <div class="detail-section">
                <h3 style="color: #E8C547; margin-bottom: 1rem;">处理结果</h3>
                <div class="result-box">
                    <div class="detail-value" style="white-space: pre-wrap;"><%=resultContent%></div>
                </div>
            </div>
            <% } else if("completed".equals(status) || "rejected".equals(status)) { %>
            <div class="detail-section">
                <h3 style="color: #E8C547; margin-bottom: 1rem;">处理结果</h3>
                <div class="result-box">
                    <div class="detail-value">管理员已处理此请求，但未提供详细结果信息。</div>
                </div>
            </div>
            <% } %>
            
            <div class="flex-center gap-2 mt-3" style="flex-wrap: wrap;">
                <a href="permission_request_list.jsp?uid=<%=userid%>" class="btn btn-primary">返回列表</a>
                <a href="loginsuccess.jsp?message=<%=userid%>" class="btn btn-secondary">返回首页</a>
            </div>
        </div>
    </div>
    <%
        } catch(Exception e) {
            e.printStackTrace();
    %>
    <div class="container">
        <div class="card fade-in">
            <div class="alert alert-error">
                <strong>加载失败</strong> <%=e.getMessage()%>
            </div>
            <div class="text-center mt-3">
                <a href="permission_request_list.jsp?uid=<%=userid%>" class="btn btn-primary">返回列表</a>
            </div>
        </div>
    </div>
    <%
        }
    %>
</body>
</html>

