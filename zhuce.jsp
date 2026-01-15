<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/11/23
  Time: 21:32
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=utf-8" language="java" %>
<%@ page   pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 用户注册</title>
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
            padding: 0.5rem 1rem;
            border: 1px solid var(--border);
        }
        
        .back-link:hover {
            color: var(--crimson);
            border-color: var(--crimson);
            background: rgba(139, 46, 46, 0.05);
        }
        
        .login-card {
            width: 100%;
            max-width: 500px;
        }
        
        .brand-section {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .brand-logo {
            font-size: 3.5rem;
            font-weight: 700;
            color: var(--crimson);
            margin-bottom: 0.75rem;
            letter-spacing: 6px;
            font-family: 'KaiTi', 'STKaiti', serif;
            position: relative;
        }
        
        .brand-logo::before,
        .brand-logo::after {
            content: '◈';
            color: var(--gold);
            font-size: 1.5rem;
            margin: 0 0.5rem;
            vertical-align: middle;
        }
        
        .brand-tagline {
            color: var(--text-secondary);
            font-size: 1.1rem;
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
            opacity: 0.5;
            pointer-events: none;
        }
        
        .form-input-wrapper {
            position: relative;
        }
        
        .form-input-wrapper .form-input {
            padding-left: 3rem;
        }
        
        .gender-select {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.75rem;
        }
        
        .gender-option {
            padding: 1rem;
            background: var(--bg-input);
            border: 1px solid var(--border);
            border-radius: 12px;
            text-align: center;
            cursor: pointer;
            transition: var(--transition);
            color: var(--text-secondary);
        }
        
        .gender-option:hover {
            background: var(--bg-input-focus);
            border-color: var(--primary);
        }
        
        .gender-option input[type="radio"] {
            display: none;
        }
        
        .gender-option:has(input[type="radio"]:checked) {
            background: var(--primary-light);
            border-color: var(--primary);
            color: var(--primary);
        }
        
        .gender-option input[type="radio"]:checked + span {
            color: var(--primary);
            font-weight: 600;
        }
        
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
                <div class="brand-tagline">创建账户 · 开启智慧出行</div>
            </div>
            
            <div class="card fade-in" style="animation-delay: 0.1s; max-width: 100%;">
                <h2 class="card-title">用户注册</h2>
                <form id="indexform" name="indexForm" action="zhucecheck.jsp" method="post">
                    <div class="form-group">
                        <label class="form-label" for="userid">身份证号</label>
                        <div class="form-input-wrapper">
                            <svg class="form-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                                <line x1="16" y1="2" x2="16" y2="6"></line>
                                <line x1="8" y1="2" x2="8" y2="6"></line>
                                <line x1="3" y1="10" x2="21" y2="10"></line>
                            </svg>
                            <input type="text" id="userid" name="userid" class="form-input" placeholder="请输入身份证号" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="name">姓名</label>
                        <div class="form-input-wrapper">
                            <svg class="form-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            <input type="text" id="name" name="name" class="form-input" placeholder="请输入真实姓名" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="password">密码</label>
                        <div class="form-input-wrapper">
                            <svg class="form-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                            </svg>
                            <input type="password" id="password" name="password" class="form-input" placeholder="请设置密码" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">性别</label>
                        <div class="gender-select">
                            <label class="gender-option">
                                <input type="radio" name="gender" value="男" required>
                                <span>男</span>
                            </label>
                            <label class="gender-option">
                                <input type="radio" name="gender" value="女" required>
                                <span>女</span>
                            </label>
                        </div>
                    </div>
                    
                    <button type="submit" class="btn btn-primary btn-block">注册</button>
                </form>
                
                <div class="text-center mt-2">
                    <span style="color: var(--text-secondary);">已有账号？</span>
                    <a href="login.jsp" class="form-link" style="margin-left: 0.5rem;">立即登录</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
