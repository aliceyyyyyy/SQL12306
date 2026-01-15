<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/11/24
  Time: 17:26
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 车票查询</title>
    <link rel="stylesheet" href="css/main.css">
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
    </style>
</head>
<body>
    <video class="video-background" autoplay muted loop playsinline preload="auto">
        <source src="Star_Rail_Wallpaper.mp4" type="video/mp4">
    </video>
    <%
        String userid=request.getParameter("message");
        if(userid == null) userid = "";
    %>
    <nav class="navbar">
        <a href="loginsuccess.jsp?message=<%=userid%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="loginsuccess.jsp?message=<%=userid%>">首页</a></li>
            <li><a href="chepiaochaxun.jsp?uid=<%=userid%>">车票查询</a></li>
            <li><a href="tuipiao.jsp">退票</a></li>
            <li><a href="gaipiao.jsp?uid=<%=userid%>">改签</a></li>
            <li><a href="searchrecord.jsp">我的订单</a></li>
            <li><a href="permission_request_list.jsp?uid=<%=userid%>">权限代理</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <%
        // 设置session
        session.setAttribute("user_id", userid);
    %>
    <div class="container">
        <h1 class="page-title">欢迎回来，<%out.println(userid);%></h1>
        <p class="page-subtitle">请选择您需要的服务模块</p>
        
        <div class="modules-grid" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 2rem; margin-top: 2rem;">
            <a href="chepiaochaxun.jsp?uid=<%=userid%>" class="module-card">
                <div class="module-icon">🔍</div>
                <div class="module-title">车票查询</div>
                <div class="module-desc">查询车次信息，购买车票（包含直达和换乘）</div>
            </a>
            
            <a href="searchrecord.jsp" class="module-card">
                <div class="module-icon">🎫</div>
                <div class="module-title">我的订单</div>
                <div class="module-desc">查看购票记录和订单信息</div>
            </a>
            
            <a href="tuipiao.jsp" class="module-card">
                <div class="module-icon">↩️</div>
                <div class="module-title">退票</div>
                <div class="module-desc">办理车票退订手续</div>
            </a>
            
            <a href="gaipiao.jsp?uid=<%=userid%>" class="module-card">
                <div class="module-icon">🔄</div>
                <div class="module-title">改签</div>
                <div class="module-desc">更改车次和发车时间</div>
            </a>
            
            <a href="view_trainlist.jsp" class="module-card">
                <div class="module-icon">📋</div>
                <div class="module-title">车次列表</div>
                <div class="module-desc">查看所有可用车次信息</div>
            </a>
            
            <a href="permission_request_list.jsp?uid=<%=userid%>" class="module-card">
                <div class="module-icon">🔐</div>
                <div class="module-title">权限代理</div>
                <div class="module-desc">提交权限请求和查看处理状态</div>
            </a>
        </div>
    </div>
    
    <style>
        .module-card {
            background: rgba(255, 255, 255, 0.75) !important;
            backdrop-filter: blur(10px);
            border: 2px solid var(--border);
            border-radius: 16px;
            padding: 2rem;
            text-align: center;
            text-decoration: none;
            color: var(--text-primary);
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 1rem;
            box-shadow: var(--shadow-sm);
        }
        
        .module-card:hover {
            transform: translateY(-8px);
            border-color: var(--crimson);
            box-shadow: var(--shadow-lg);
            background: rgba(255, 255, 255, 0.8) !important;
            opacity: 1 !important;
        }
        
        .module-icon {
            font-size: 3rem;
            margin-bottom: 0.5rem;
        }
        
        .module-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--text-primary);
        }
        
        .module-desc {
            font-size: 0.9rem;
            color: var(--text-secondary);
            line-height: 1.5;
        }
    </style>
    </div>
</body>
</html>

