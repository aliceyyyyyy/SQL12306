<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/11/24
  Time: 17:26
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 注册成功</title>
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
    <div class="container">
        <div class="card fade-in">
            <div class="alert alert-success">
                <strong>注册成功！</strong> 欢迎成为 列国驿轨系统 高速铁路会员
            </div>
            <h2 class="card-title">会员权益</h2>
            <ul style="list-style: none; padding: 0; margin: 1.5rem 0;">
                <li style="padding: 0.75rem; background: var(--bg-hover); margin-bottom: 0.5rem; border-radius: 4px;">1. 极速购票通道，优先保障</li>
                <li style="padding: 0.75rem; background: var(--bg-hover); margin-bottom: 0.5rem; border-radius: 4px;">2. 24小时在线客服支持</li>
                <li style="padding: 0.75rem; background: var(--bg-hover); margin-bottom: 0.5rem; border-radius: 4px;">3. 新用户专享优惠服务</li>
            </ul>
            <div class="btn-group">
                <a href="login.jsp" class="btn btn-primary btn-block">立即登录</a>
            </div>
        </div>
    </div>
</body>
</html>