<%--
  列国驿轨系统 高速铁路 - 首页选择页面
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        body {
            margin: 0;
            padding: 0;
            overflow-x: hidden;
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
        
        .hero-section {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            background: transparent;
            position: relative;
            overflow: hidden;
        }
        
        .hero-section::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 200px;
            background: linear-gradient(180deg, transparent, rgba(139, 46, 46, 0.08));
            pointer-events: none;
            animation: gradientShift 3s ease-in-out infinite;
        }
        
        @keyframes gradientShift {
            0%, 100% { opacity: 0.5; }
            50% { opacity: 0.8; }
        }
        
        .hero-title {
            font-size: 5rem;
            font-weight: 700;
            color: #E8C547;
            margin-bottom: 1.5rem;
            letter-spacing: 12px;
            font-family: 'KaiTi', 'STKaiti', serif;
            position: relative;
            text-shadow: 0 4px 12px rgba(139, 46, 46, 0.3),
                         0 0 30px rgba(212, 175, 55, 0.2);
            animation: titleGlow 3s ease-in-out infinite;
            z-index: 2;
        }
        
        @keyframes titleGlow {
            0%, 100% {
                text-shadow: 0 4px 12px rgba(139, 46, 46, 0.3),
                             0 0 30px rgba(212, 175, 55, 0.2);
            }
            50% {
                text-shadow: 0 4px 12px rgba(139, 46, 46, 0.5),
                             0 0 40px rgba(212, 175, 55, 0.4);
            }
        }
        
        .hero-title::before,
        .hero-title::after {
            content: '◆';
            color: var(--gold);
            font-size: 2.5rem;
            margin: 0 1.5rem;
            vertical-align: middle;
            animation: symbolRotate 4s linear infinite;
            display: inline-block;
        }
        
        @keyframes symbolRotate {
            0% { transform: rotate(0deg) scale(1); }
            50% { transform: rotate(180deg) scale(1.2); }
            100% { transform: rotate(360deg) scale(1); }
        }
        
        .hero-subtitle {
            font-size: 1.75rem;
            color: #E0E0DB;
            margin-bottom: 4rem;
            font-weight: 400;
            font-style: italic;
            letter-spacing: 6px;
            animation: subtitleFloat 3s ease-in-out infinite;
            z-index: 2;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
        }
        
        @keyframes subtitleFloat {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }
        
        /* 背景装饰元素 */
        .hero-section .floating-element {
            position: absolute;
            width: 100px;
            height: 100px;
            background: radial-gradient(circle, rgba(212, 175, 55, 0.1) 0%, transparent 70%);
            border-radius: 50%;
            animation: float 6s ease-in-out infinite;
            pointer-events: none;
            z-index: 1;
        }
        
        .hero-section .floating-element:nth-child(1) {
            top: 10%;
            left: 10%;
            animation-delay: 0s;
        }
        
        .hero-section .floating-element:nth-child(2) {
            top: 20%;
            right: 15%;
            animation-delay: 2s;
            width: 150px;
            height: 150px;
        }
        
        .hero-section .floating-element:nth-child(3) {
            bottom: 15%;
            left: 20%;
            animation-delay: 4s;
            width: 80px;
            height: 80px;
        }
        
        @keyframes float {
            0%, 100% {
                transform: translate(0, 0) scale(1);
                opacity: 0.3;
            }
            50% {
                transform: translate(30px, -30px) scale(1.2);
                opacity: 0.6;
            }
        }
        
        @media (max-width: 768px) {
            .hero-title {
                font-size: 2.5rem;
            }
            
            .choice-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <video class="video-background" autoplay muted loop playsinline preload="auto">
        <source src="ruanmei.mp4" type="video/mp4">
    </video>
    <div class="hero-section">
        <!-- 浮动装饰元素 -->
        <div class="floating-element"></div>
        <div class="floating-element"></div>
        <div class="floating-element"></div>
        
        <div class="brand-section fade-in">
            <h1 class="hero-title">列国驿轨系统</h1>
            <p class="hero-subtitle">高速铁路 · 智慧出行</p>
        </div>
        
        <div class="choice-grid fade-in" style="animation-delay: 0.3s; display: flex; flex-direction: row; justify-content: center; gap: 2rem; flex-wrap: wrap;">
            <a href="login.jsp" class="choice-card">
                <div class="choice-card-icon">👤</div>
                <div class="choice-card-title">用户登录</div>
                <div class="choice-card-desc">查询车次、购买车票、管理订单</div>
            </a>
            
            <a href="admin/login.jsp" class="choice-card">
                <div class="choice-card-icon">🔧</div>
                <div class="choice-card-title">管理员登录</div>
                <div class="choice-card-desc">系统管理、数据维护、运营管理</div>
            </a>
        </div>
    </div>
    
    <script>
        // 添加鼠标跟随光效
        document.addEventListener('mousemove', function(e) {
            const cards = document.querySelectorAll('.choice-card');
            cards.forEach(card => {
                const rect = card.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                
                const centerX = rect.width / 2;
                const centerY = rect.height / 2;
                
                const rotateX = (y - centerY) / 10;
                const rotateY = (centerX - x) / 10;
                
                card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-12px) scale(1.05)`;
            });
        });
        
        document.addEventListener('mouseleave', function() {
            const cards = document.querySelectorAll('.choice-card');
            cards.forEach(card => {
                card.style.transform = '';
            });
        });
    </script>
</body>
</html>

