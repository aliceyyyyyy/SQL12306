<%--
  列国驿轨系统 高速铁路 - 管理员登录页面
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 管理员登录</title>
    <link rel="stylesheet" href="../css/main.css">
    <style>
        .login-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            background: transparent;
            position: relative;
        }
        
        .login-card {
            width: 100%;
            max-width: 480px;
        }
        
        .brand-section {
            text-align: center;
            margin-bottom: 2.5rem;
        }
        
        .brand-logo {
            font-size: 3.5rem;
            font-weight: 700;
            color: #E8C547 !important;
            margin-bottom: 0.75rem;
            letter-spacing: 6px;
            font-family: 'KaiTi', 'STKaiti', serif;
            position: relative;
            text-shadow: 0 2px 8px rgba(232, 197, 71, 0.5) !important;
        }
        
        .brand-logo::before,
        .brand-logo::after {
            content: '◈';
            color: #E8C547 !important;
            font-size: 1.5rem;
            margin: 0 0.5rem;
            vertical-align: middle;
        }
        
        .brand-tagline {
            color: #E0E0DB !important;
            font-size: 1.1rem;
            font-weight: 400;
            font-style: italic;
            letter-spacing: 2px;
        }
        
        .form-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            width: 20px;
            height: 20px;
            opacity: 0.6;
            pointer-events: none;
            color: #E0E0DB !important;
        }
        
        .form-input-wrapper {
            position: relative;
        }
        
        .form-input-wrapper .form-input {
            padding-left: 3rem !important;
            background: rgba(25, 25, 30, 0.85) !important;
            border: 1.5px solid rgba(212, 196, 176, 0.4) !important;
            color: #F5F5F0 !important;
        }
        
        .form-input-wrapper .form-input::placeholder {
            color: #B8B8B3 !important;
        }
        
        .form-input-wrapper .form-input:hover {
            border-color: rgba(212, 196, 176, 0.6) !important;
            background: rgba(30, 30, 35, 0.9) !important;
        }
        
        .form-input-wrapper .form-input:focus {
            border-color: #E8C547 !important;
            background: rgba(30, 30, 35, 0.95) !important;
            box-shadow: 0 0 0 3px rgba(232, 197, 71, 0.3) !important;
            color: #F5F5F0 !important;
        }
        
        .login-container .form-label {
            color: #E0E0DB !important;
        }
        
        .divider {
            display: flex;
            align-items: center;
            margin: 2rem 0;
            color: #B8B8B3 !important;
            font-size: 0.875rem;
        }
        
        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            height: 2px;
            background: linear-gradient(90deg, transparent, #E8C547, transparent) !important;
        }
        
        .divider span {
            padding: 0 1rem;
            color: #E8C547 !important;
            font-weight: 500;
        }
        
        .back-link {
            position: absolute;
            top: 2rem;
            left: 2rem;
            color: #E0E0DB !important;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            transition: var(--transition);
            padding: 0.5rem 1rem;
            border: 1px solid rgba(212, 196, 176, 0.4) !important;
            background: rgba(25, 25, 30, 0.7) !important;
            backdrop-filter: blur(10px) !important;
        }
        
        .back-link:hover {
            color: #E8C547 !important;
            border-color: #E8C547 !important;
            background: rgba(232, 197, 71, 0.15) !important;
        }
        
        .admin-hint {
            background: rgba(30, 30, 35, 0.9) !important;
            border-left: 4px solid #E8C547 !important;
            padding: 1rem;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
            color: #E0E0DB !important;
            backdrop-filter: blur(10px) !important;
        }
        
        .admin-hint strong {
            color: #E8C547 !important;
        }
        
        .login-container .card {
            background: rgba(25, 25, 30, 0.88) !important;
            backdrop-filter: blur(15px) !important;
            border-color: rgba(212, 196, 176, 0.4) !important;
        }
        
        .login-container .card-title {
            color: #F5F5F0 !important;
        }
        
        /* 闅愯棌body鑳屾櫙鍥剧墖锛岄伩鍏嶅湪瑙嗛鍔犺浇鍓嶆樉绀?*/
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
    </style>
</head>
<body>
    <video class="video-background" autoplay muted loop playsinline preload="auto">
        <source src="../HEVC 王者荣耀 王者冰刃.mp4" type="video/mp4">
    </video>
    <div class="login-container">
        <a href="../index.jsp" class="back-link">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
            返回首页
        </a>
        
        <div class="login-card">
            <div class="brand-section fade-in">
                <div class="brand-logo">列国驿轨系统</div>
                <div class="brand-tagline">管理员登录 · 系统管理</div>
            </div>
            
            <div class="card fade-in" style="animation-delay: 0.1s;">
                <div class="admin-hint">
                    <strong>管理员账号说明：</strong><br>
                    • user_admin - 普通用户管理员<br>
                    • train_admin - 车次信息管理员<br>
                    • root - 数据库维护人员（超级用户）
                </div>
                
                <h2 class="card-title">管理员登录</h2>
                <form id="adminForm" name="adminForm" action="logincheck.jsp" method="post">
                    <div class="form-group">
                        <label class="form-label" for="username">管理员账号</label>
                        <div class="form-input-wrapper">
                            <svg class="form-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <input type="text" id="username" name="username" class="form-input" placeholder="请输入管理员账号" required autocomplete="username">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="password">密码</label>
                        <div class="form-input-wrapper">
                            <svg class="form-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                            </svg>
                            <input type="password" id="password" name="password" class="form-input" placeholder="请输入密码" required autocomplete="current-password">
                        </div>
                    </div>
                    
                    <button type="submit" class="btn btn-primary btn-block">登录</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>


