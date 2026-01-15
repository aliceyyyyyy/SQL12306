<%--
  列国驿轨系统 高速铁路 - 权限代理服务 - 管理员处理请求
  管理员查看请求详情并处理请求
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
    
    String requestId = request.getParameter("request_id");
    String action = request.getParameter("action");
    
    if(requestId == null) {
        response.sendRedirect("permission_requests.jsp");
        return;
    }
    
    // 处理请求操作
    if("process".equals(action)) {
        String status = request.getParameter("status");
        String resultContent = request.getParameter("result_content");
        String resultData = request.getParameter("result_data");
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
            // 统一使用 root 用户连接，因为 permission_request 表是系统级别的，需要完整权限
            String dbUser = "root";
            String dbPass = "bei060805";
            Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
            
            System.out.println("管理员处理权限申请 - 角色: " + adminRole + ", 请求ID: " + requestId);
            
            // 先检查请求是否存在且属于当前管理员可处理的角色
            Statement checkStmt = conn.createStatement();
            String checkSql = "SELECT * FROM permission_request WHERE request_id = '" + requestId + "'";
            ResultSet checkRs = checkStmt.executeQuery(checkSql);
            
            if(checkRs.next()) {
                String reqAdminRole = checkRs.getString("admin_role");
                String reqType = checkRs.getString("request_type");
                boolean canProcess = false;
                
                // 权限分层检查
                if("super_admin".equals(adminRole)) {
                    // 超级管理员可以处理所有请求
                    canProcess = true;
                } else if("user_admin".equals(adminRole)) {
                    // 用户管理员只能处理用户管理类型的请求
                    canProcess = "user_admin".equals(reqAdminRole) && ("user_manage".equals(reqType) || "other".equals(reqType));
                } else if("train_admin".equals(adminRole)) {
                    // 车次管理员只能处理车次、车票、座位管理类型的请求
                    canProcess = "train_admin".equals(reqAdminRole) && ("train_manage".equals(reqType) || "ticket_manage".equals(reqType) || "seat_manage".equals(reqType));
                }
                
                System.out.println("权限检查 - 管理员角色: " + adminRole + ", 请求角色: " + reqAdminRole + ", 请求类型: " + reqType + ", 允许处理: " + canProcess);
                
                if(canProcess) {
                    // 更新请求状态
                    String updateSql = "UPDATE permission_request SET status = ?, assigned_admin = ?, ";
                    
                    if("processing".equals(status)) {
                        updateSql += "assign_time = NOW(), ";
                    } else if("completed".equals(status) || "rejected".equals(status)) {
                        updateSql += "complete_time = NOW(), ";
                    }
                    
                    updateSql += "result_content = ?, result_data = ? WHERE request_id = ?";
                    
                    PreparedStatement pstmt = conn.prepareStatement(updateSql);
                    pstmt.setString(1, status);
                    pstmt.setString(2, adminUser);
                    pstmt.setString(3, resultContent != null ? resultContent : "");
                    pstmt.setString(4, resultData != null ? resultData : "");
                    pstmt.setString(5, requestId);
                    pstmt.executeUpdate();
                    
                    // 如果是处理中状态，更新分配时间
                    if("processing".equals(status)) {
                        Statement updateAssignStmt = conn.createStatement();
                        updateAssignStmt.executeUpdate("UPDATE permission_request SET assign_time = NOW() WHERE request_id = '" + requestId + "' AND assign_time IS NULL");
                    }
                    
                    response.sendRedirect("permission_requests.jsp?success=1");
                    conn.close();
                    return;
                } else {
                    response.sendRedirect("permission_requests.jsp?error=权限不足");
                    conn.close();
                    return;
                }
            } else {
                response.sendRedirect("permission_requests.jsp?error=请求不存在");
                conn.close();
                return;
            }
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("permission_process.jsp?request_id=" + requestId + "&error=" + e.getMessage());
            return;
        }
    }
    
    // 显示请求详情和处理表单
    try {
        Class.forName("com.mysql.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
        // 统一使用 root 用户连接，因为 permission_request 表是系统级别的，需要完整权限
        String dbUser = "root";
        String dbPass = "bei060805";
        Connection conn = DriverManager.getConnection(url, dbUser, dbPass);
        Statement stmt = conn.createStatement();
        
        System.out.println("管理员查看权限申请详情 - 角色: " + adminRole + ", 请求ID: " + requestId);
        
        String sql = "SELECT * FROM permission_request WHERE request_id = '" + requestId + "'";
        ResultSet rs = stmt.executeQuery(sql);
        
        if(!rs.next()) {
            conn.close();
            response.sendRedirect("permission_requests.jsp");
            return;
        }
        
        String userId = rs.getString("user_id");
        String requestType = rs.getString("request_type");
        String requestTitle = rs.getString("request_title");
        String requestContent = rs.getString("request_content");
        String requestParams = rs.getString("request_params");
        String reqAdminRole = rs.getString("admin_role");
        String status = rs.getString("status");
        Timestamp createTime = rs.getTimestamp("create_time");
        String resultContent = rs.getString("result_content");
        
        // 权限分层检查
        boolean canProcess = false;
        String reqType = rs.getString("request_type");
        
        if("super_admin".equals(adminRole)) {
            // 超级管理员可以处理所有请求
            canProcess = true;
        } else if("user_admin".equals(adminRole)) {
            // 用户管理员只能处理用户管理类型的请求
            canProcess = "user_admin".equals(reqAdminRole) && ("user_manage".equals(reqType) || "other".equals(reqType));
        } else if("train_admin".equals(adminRole)) {
            // 车次管理员只能处理车次、车票、座位管理类型的请求
            canProcess = "train_admin".equals(reqAdminRole) && ("train_manage".equals(reqType) || "ticket_manage".equals(reqType) || "seat_manage".equals(reqType));
        }
        
        System.out.println("权限检查 - 管理员角色: " + adminRole + ", 请求角色: " + reqAdminRole + ", 请求类型: " + reqType + ", 允许处理: " + canProcess);
        
        if(!canProcess) {
            conn.close();
            response.sendRedirect("permission_requests.jsp?error=权限不足，您无法处理此类型的请求");
            return;
        }
        
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
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>处理请求 - 列国驿轨系统 高速铁路</title>
    <link rel="stylesheet" href="../css/main.css">
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
            <li><a href="permission_requests.jsp" class="active">权限代理</a></li>
            <li><a href="../index.jsp">返回前台</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
            <div>
                <h1 class="page-title">处理权限提升请求</h1>
                <p class="page-subtitle">请求编号：<%=requestId%></p>
            </div>
            <span class="status-badge <%=statusClass%>"><%=statusText%></span>
        </div>
        
        <div class="card fade-in">
            <div class="detail-section">
                <h3 style="color: #E8C547; margin-bottom: 1rem;">请求信息</h3>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem;">
                    <div>
                        <div class="detail-label">用户ID</div>
                        <div class="detail-value"><%=userId%></div>
                    </div>
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
                <div class="detail-label">已有处理结果</div>
                <div class="detail-value" style="white-space: pre-wrap; background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(10px); padding: 1rem; border-radius: 4px;"><%=resultContent%></div>
            </div>
            <% } %>
            
            <div class="detail-section">
                <h3 style="color: #E8C547; margin-bottom: 1rem;">处理请求</h3>
                <form action="permission_process.jsp" method="post">
                    <input type="hidden" name="request_id" value="<%=requestId%>">
                    <input type="hidden" name="action" value="process">
                    
                    <div class="form-group">
                        <label class="form-label">处理状态 <span style="color: #E8C547;">*</span></label>
                        <select name="status" class="form-input" required>
                            <option value="processing" <%="processing".equals(status) ? "selected" : ""%>>处理中</option>
                            <option value="completed" <%="completed".equals(status) ? "selected" : ""%>>已完成</option>
                            <option value="rejected" <%="rejected".equals(status) ? "selected" : ""%>>已拒绝</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="result_content">处理结果说明</label>
                        <textarea id="result_content" name="result_content" class="form-input" rows="6" 
                                  placeholder="请详细说明处理过程和结果..."><%=resultContent != null ? resultContent : ""%></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="result_data">处理结果数据（JSON格式，可选）</label>
                        <textarea id="result_data" name="result_data" class="form-input" rows="4" 
                                  placeholder='例如：{"success": true, "data": {...}}'></textarea>
                    </div>
                    
                    <div class="btn-group">
                        <button type="submit" class="btn btn-primary btn-block">提交处理结果</button>
                        <a href="permission_requests.jsp" class="btn btn-secondary btn-block">返回列表</a>
                    </div>
                </form>
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
                <a href="permission_requests.jsp" class="btn btn-primary">返回列表</a>
            </div>
        </div>
    </div>
<%
    }
%>
</body>
</html>

