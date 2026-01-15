<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/12/1
  Time: 13:57
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page   pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 退票</title>
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
        
        .form-label {
            color: #E0E0DB !important;
        }
    </style>
</head>
<body>
    <video class="video-background" autoplay muted loop playsinline preload="auto">
        <source src="Star_Rail_Wallpaper.mp4" type="video/mp4">
    </video>
    <%
        String userid = (String)session.getAttribute("user_id");
        if(userid == null) {
            userid = request.getParameter("uid");
        }
        if(userid == null) userid = "";
        String ticketnum = request.getParameter("ticket");
        String homeLink = userid != null && !userid.isEmpty() ? "loginsuccess.jsp?message=" + userid : "loginsuccess.jsp";
    %>
    <nav class="navbar">
        <a href="<%=homeLink%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="<%=homeLink%>">首页</a></li>
            <li><a href="chepiaochaxun.jsp?uid=<%=userid%>">车票查询</a></li>
            <li><a href="tuipiao.jsp">退票</a></li>
            <li><a href="gaipiao.jsp?uid=<%=userid%>">改签</a></li>
            <li><a href="searchrecord.jsp">我的订单</a></li>
            <li><a href="permission_request_list.jsp?uid=<%=userid%>">权限代理</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">车票退订</h1>
        <p class="page-subtitle">请输入相关信息以完成退票操作</p>
        
        <div class="card fade-in" style="max-width: 100%;">
            <h2 class="card-title">退票验证</h2>
            <form id="indexform" name="indexForm" action="tuipiaocheck.jsp" method="post">
                <div class="form-group">
                    <label class="form-label" for="id">账号</label>
                    <div class="form-input-wrapper username">
                        <input type="text" id="id" name="id" class="form-input" value="<%=userid != null ? userid : ""%>" placeholder="请输入您的账号" required>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="password">密码</label>
                    <div class="form-input-wrapper password">
                        <input type="password" id="password" name="password" class="form-input" placeholder="请输入您的密码" required>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="ticket">待退车票号</label>
                    <div class="form-input-wrapper ticket">
                        <input type="text" id="ticket" name="ticket" class="form-input" value="<%=ticketnum != null ? ticketnum : ""%>" placeholder="请输入车票编号（字母+数字组合）" required pattern="[A-Za-z0-9]+" oninput="validateTicket(this)" <%if(ticketnum != null) {%>readonly<%}%>>
                    </div>
                    <small id="ticket-hint" style="display: none; color: var(--rail-red); font-size: 0.875rem; margin-top: 0.25rem;">车票号格式不正确，应为字母和数字组合</small>
                    <% if(ticketnum != null) { %>
                    <small style="color: var(--text-secondary); font-size: 0.875rem; margin-top: 0.25rem;">已从订单选择，不可修改</small>
                    <% } %>
                </div>
                <div class="alert alert-warning">
                    <strong>退票须知：</strong> 退票将收取手续费，退款将在1-3个工作日内原路退回您的支付账户
                </div>
                <div class="btn-group">
                    <button type="submit" class="btn btn-primary btn-block" onclick="return confirmRefund(event)">确认退票</button>
                </div>
            </form>
    
    <script>
        function validateTicket(input) {
            const value = input.value.trim();
            const hint = document.getElementById('ticket-hint');
            const ticketPattern = /^[A-Za-z0-9]+$/;
            
            if (value && !ticketPattern.test(value)) {
                hint.style.display = 'block';
                input.style.borderColor = 'var(--rail-red)';
                return false;
            } else {
                hint.style.display = 'none';
                input.style.borderColor = '';
                return true;
            }
        }
        
        function confirmRefund(event) {
            const ticket = document.getElementById('ticket').value.trim();
            if (!ticket) {
                alert('请输入车票编号');
                event.preventDefault();
                return false;
            }
            
            if (!validateTicket(document.getElementById('ticket'))) {
                event.preventDefault();
                return false;
            }
            
            const confirmMsg = '确认退票？\n\n' +
                '车票号：' + ticket + '\n' +
                '手续费：按票价的10%收取\n' +
                '退款到账：1-3个工作日\n\n' +
                '确定要继续吗？';
            
            if (!confirm(confirmMsg)) {
                event.preventDefault();
                return false;
            }
            
            return true;
        }
    </script>
        </div>
    </div>
</body>
</html>