<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/11/23
  Time: 21:32
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
    <title>列国驿轨系统 高速铁路 - 用户登录</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .login-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            background: transparent;
            position: relative;
            overflow: hidden;
        }
        
        .login-container::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -20%;
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(212, 175, 55, 0.15) 0%, transparent 70%);
            animation: loginGlow 8s ease-in-out infinite;
            pointer-events: none;
            z-index: 0;
        }
        
        @keyframes loginGlow {
            0%, 100% {
                transform: translate(0, 0) scale(1);
                opacity: 0.5;
            }
            50% {
                transform: translate(-50px, 50px) scale(1.2);
                opacity: 0.8;
            }
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
            color: var(--crimson);
            margin-bottom: 0.75rem;
            letter-spacing: 6px;
            font-family: 'KaiTi', 'STKaiti', serif;
            position: relative;
            text-shadow: 0 2px 8px rgba(139, 46, 46, 0.3);
            animation: logoGlow 3s ease-in-out infinite;
        }
        
        @keyframes logoGlow {
            0%, 100% {
                text-shadow: 0 2px 8px rgba(139, 46, 46, 0.3);
            }
            50% {
                text-shadow: 0 2px 8px rgba(139, 46, 46, 0.5),
                             0 0 20px rgba(212, 175, 55, 0.3);
            }
        }
        
        .brand-logo::before,
        .brand-logo::after {
            content: '◈';
            color: var(--gold);
            font-size: 1.5rem;
            margin: 0 0.5rem;
            vertical-align: middle;
            display: inline-block;
            animation: symbolPulse 2s ease-in-out infinite;
        }
        
        @keyframes symbolPulse {
            0%, 100% { transform: scale(1); opacity: 0.8; }
            50% { transform: scale(1.3); opacity: 1; }
        }
        
        .brand-tagline {
            color: var(--text-secondary);
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
            opacity: 0.4;
            pointer-events: none;
        }
        
        .form-input-wrapper {
            position: relative;
        }
        
        .form-input-wrapper .form-input {
            padding-left: 3rem;
        }
        
        .divider {
            display: flex;
            align-items: center;
            margin: 2rem 0;
            color: var(--text-muted);
            font-size: 0.875rem;
        }
        
        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            height: 2px;
            background: linear-gradient(90deg, transparent, var(--crimson), transparent);
        }
        
        .divider span {
            padding: 0 1rem;
            color: var(--crimson);
            font-weight: 500;
        }
        
        .back-link {
            position: absolute;
            top: 2rem;
            left: 2rem;
            color: var(--text-secondary);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            transition: var(--transition);
        }
        
        .back-link:hover {
            color: var(--primary);
        }
        
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
        <source src="Star_Rail_Wallpaper.mp4" type="video/mp4">
    </video>
    <div class="login-container">
        <a href="index.jsp" class="back-link">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
            返回首页
        </a>
        
        <div class="login-card">
            <div class="brand-section fade-in">
                <div class="brand-logo">列国驿轨系统</div>
                <div class="brand-tagline">用户登录 · 开启智慧出行</div>
            </div>
            
            <div class="card fade-in" style="animation-delay: 0.1s; max-width: 100%;">
                <h2 class="card-title">欢迎回来</h2>
                <form id="indexform" name="indexForm" action="logincheck.jsp" method="post">
                    <div class="form-group">
                        <label class="form-label" for="id">账号</label>
                        <div class="form-input-wrapper">
                            <svg class="form-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <input type="text" id="id" name="id" class="form-input" placeholder="请输入身份证号" required autocomplete="username">
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
                    
                    <div class="checkbox-group">
                        <label class="checkbox-label">
                            <input type="checkbox" name="remember" class="checkbox-input" value="1">
                            <span>记住账号</span>
                        </label>
                        <a href="#" class="form-link">忘记密码？</a>
                    </div>
                    
                    <button type="submit" class="btn btn-primary btn-block">登录</button>
                </form>
                
                <div class="divider">
                    <span>或</span>
                </div>
                
                <div class="text-center">
                    <span style="color: var(--text-secondary);">还没有账号？</span>
                    <a href="zhuce.jsp" class="form-link" style="margin-left: 0.5rem;">立即注册</a>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        window.addEventListener('DOMContentLoaded', function() {
            const savedId = localStorage.getItem('savedUserId');
            const rememberCheckbox = document.querySelector('input[name="remember"]');
            
            if (savedId) {
                document.getElementById('id').value = savedId;
                if (rememberCheckbox) rememberCheckbox.checked = true;
            }
            
            const form = document.getElementById('indexform');
            form.addEventListener('submit', function() {
                const userId = document.getElementById('id').value;
                if (rememberCheckbox && rememberCheckbox.checked) {
                    localStorage.setItem('savedUserId', userId);
                } else {
                    localStorage.removeItem('savedUserId');
                }
            });
        });
    </script>
</body>
</html>
