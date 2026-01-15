<%--
  列国驿轨系统 高速铁路 - 权限代理服务 - 提交权限提升请求
  当用户需要使用需要更高权限的功能时，可以通过此页面提交请求
--%>
<%@ page language="java" import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>权限代理服务 - 列国驿轨系统 高速铁路</title>
    <link rel="stylesheet" href="css/main.css">
    <style>
        .request-type-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin: 1.5rem 0;
        }
        .request-type-card {
            padding: 1rem;
            border: 2px solid var(--border);
            border-radius: 8px;
            cursor: pointer;
            transition: var(--transition);
            text-align: center;
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(10px);
            user-select: none;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
        }
        .request-type-card:hover {
            border-color: #E8C547;
            background: var(--bg-hover);
            transform: translateY(-2px);
        }
        .request-type-card.selected {
            border-color: #E8C547;
            background: var(--bg-secondary);
        }
        .request-type-card .icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        .request-type-card .title {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.25rem;
        }
        .request-type-card .desc {
            font-size: 0.875rem;
            color: var(--text-secondary);
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
        <h1 class="page-title">权限代理服务</h1>
        <p class="page-subtitle">当您需要使用需要更高权限的功能时，可以提交请求，系统将为您分配相应的管理员进行处理</p>
        
        <div class="card fade-in">
            <h2 class="card-title">提交权限提升请求</h2>
            <form action="permission_request_submit.jsp" method="post" id="requestForm">
                <input type="hidden" name="uid" value="<%=userid%>">
                
                <div class="form-group">
                    <label class="form-label">请求类型 <span style="color: #E8C547;">*</span></label>
                    <div class="request-type-grid" id="request-type-grid">
                        <div class="request-type-card" data-type="user_manage">
                            <div class="icon">👤</div>
                            <div class="title">用户管理</div>
                            <div class="desc">修改用户信息、密码重置等</div>
                        </div>
                        <div class="request-type-card" data-type="train_manage">
                            <div class="icon">🚄</div>
                            <div class="title">车次管理</div>
                            <div class="desc">添加、修改、删除车次信息</div>
                        </div>
                        <div class="request-type-card" data-type="ticket_manage">
                            <div class="icon">🎫</div>
                            <div class="title">车票管理</div>
                            <div class="desc">车票查询、修改、删除操作</div>
                        </div>
                        <div class="request-type-card" data-type="seat_manage">
                            <div class="icon">🪑</div>
                            <div class="title">座位管理</div>
                            <div class="desc">座位信息查看、修改</div>
                        </div>
                        <div class="request-type-card" data-type="other">
                            <div class="icon">📋</div>
                            <div class="title">其他请求</div>
                            <div class="desc">其他需要管理员权限的操作</div>
                        </div>
                    </div>
                    <input type="hidden" name="request_type" id="request_type" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="request_title">请求标题 <span style="color: #E8C547;">*</span></label>
                    <input type="text" id="request_title" name="request_title" class="form-input" 
                           placeholder="请简要描述您的需求，例如：修改用户姓名" required>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="request_content">详细说明</label>
                    <textarea id="request_content" name="request_content" class="form-input" rows="6" 
                              placeholder="请详细描述您的需求，包括具体要执行的操作和相关信息..."></textarea>
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="request_params">请求参数（JSON格式，可选）</label>
                    <textarea id="request_params" name="request_params" class="form-input" rows="4" 
                              placeholder='例如：{"user_id": "123456789", "field": "name", "value": "新姓名"}'></textarea>
                    <small style="color: var(--text-muted);">如果需要传递结构化参数，请使用JSON格式</small>
                </div>
                
                <div class="btn-group">
                    <button type="submit" class="btn btn-primary btn-block">提交请求</button>
                    <a href="loginsuccess.jsp?message=<%=userid%>" class="btn btn-secondary btn-block">取消</a>
                </div>
            </form>
        </div>
        
        <div class="card fade-in" style="margin-top: 2rem;">
            <h3 style="color: #E8C547; margin-bottom: 1rem;">📌 使用说明</h3>
            <ul style="line-height: 2; color: var(--text-secondary);">
                <li>当您需要使用需要管理员权限的功能时，可以通过此页面提交请求</li>
                <li>系统会根据请求类型自动分配相应的管理员（可能是自动化处理）</li>
                <li>管理员处理完成后，您可以在"我的请求"页面查看处理结果</li>
                <li>处理时间通常为几分钟到几小时不等，请耐心等待</li>
            </ul>
        </div>
    </div>
    
    <script>
        // 页面加载完成后初始化
        document.addEventListener('DOMContentLoaded', function() {
            // 为所有请求类型卡片添加点击事件
            const cards = document.querySelectorAll('.request-type-card');
            cards.forEach(function(card) {
                card.addEventListener('click', function() {
                    const type = this.getAttribute('data-type');
                    selectType(type);
                });
            });
            
            // 表单提交验证
            const form = document.getElementById('requestForm');
            if (form) {
                form.addEventListener('submit', function(e) {
                    const requestType = document.getElementById('request_type').value;
                    if (!requestType) {
                        e.preventDefault();
                        alert('请选择请求类型');
                        return false;
                    }
                });
            }
        });
        
        function selectType(type) {
            // 清除所有选中状态
            const allCards = document.querySelectorAll('.request-type-card');
            for (let i = 0; i < allCards.length; i++) {
                allCards[i].classList.remove('selected');
            }
            
            // 设置选中状态
            const selectedCard = document.querySelector('[data-type="' + type + '"]');
            if (selectedCard) {
                selectedCard.classList.add('selected');
            }
            
            // 设置隐藏字段的值
            const hiddenInput = document.getElementById('request_type');
            if (hiddenInput) {
                hiddenInput.value = type;
            }
        }
    </script>
</body>
</html>

