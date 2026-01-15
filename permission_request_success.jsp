<%--
  列国驿轨系统 高速铁路 - 权限代理服务 - 请求提交成功
--%>
<%@ page language="java" import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>请求提交成功 - 列国驿轨系统 高速铁路</title>
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
        String requestId = request.getParameter("request_id");
        if(userid == null) {
            response.sendRedirect("login.jsp");
            return;
        }
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
        <div class="card fade-in">
            <div class="alert alert-success" style="font-size: 1.25rem;">
                <span style="font-size: 2rem; margin-right: 0.5rem;">✓</span>
                <strong>请求提交成功！</strong>
            </div>
            
            <div style="padding: 2rem; background: var(--bg-secondary); border-radius: 8px; margin: 2rem 0;">
                <h3 style="color: #E8C547; margin-bottom: 1rem;">请求信息</h3>
                <div style="display: grid; grid-template-columns: auto 1fr; gap: 1rem; align-items: center;">
                    <div style="font-weight: 600; color: var(--text-secondary);">请求编号：</div>
                    <div style="font-family: monospace; color: var(--text-primary); font-size: 1.1rem;"><%=requestId != null ? requestId : "未知"%></div>
                    
                    <div style="font-weight: 600; color: var(--text-secondary);">当前状态：</div>
                    <div>
                        <span style="display: inline-block; padding: 0.25rem 0.75rem; background: var(--gold-light); color: #E8C547; border-radius: 4px; font-weight: 600;">
                            待处理
                        </span>
                    </div>
                </div>
            </div>
            
            <div style="padding: 1.5rem; background: var(--bg-hover); border-left: 4px solid #E8C547; border-radius: 4px; margin: 1.5rem 0;">
                <h4 style="color: #E8C547; margin-bottom: 0.75rem;">📌 下一步</h4>
                <ul style="line-height: 2; color: var(--text-secondary); margin: 0; padding-left: 1.5rem;">
                    <li>您的请求已成功提交，系统将自动分配相应的管理员进行处理</li>
                    <li>您可以在"我的请求"页面随时查看请求的处理进度和结果</li>
                    <li>处理完成后，系统会将结果反馈给您</li>
                </ul>
            </div>
            
            <div class="flex-center gap-2 mt-3" style="flex-wrap: wrap;">
                <a href="permission_request_list.jsp?uid=<%=userid%>" class="btn btn-primary">查看我的请求</a>
                <a href="permission_request.jsp?uid=<%=userid%>" class="btn btn-secondary">继续提交请求</a>
                <a href="loginsuccess.jsp?message=<%=userid%>" class="btn btn-outline">返回首页</a>
            </div>
        </div>
    </div>
</body>
</html>

