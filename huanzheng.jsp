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
    <title>列国驿轨系统 高速铁路 - 换乘查询</title>
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
        String userid=request.getParameter("uid");
        if(userid == null) userid = "";
    %>
    <nav class="navbar">
        <%
            if(userid == null) {
                userid = (String)session.getAttribute("user_id");
            }
            if(userid == null) userid = "";
            String homeLink = "loginsuccess.jsp?message=" + userid;
        %>
        <a href="<%=homeLink%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="<%=homeLink%>">首页</a></li>
            <li><a href="chepiaochaxun.jsp?uid=<%=userid%>">车票查询</a></li>
            <li><a href="tuipiao.jsp">退票</a></li>
            <li><a href="gaipiao.jsp?uid=<%=userid%>">改签</a></li>
            <li><a href="huanzheng.jsp?uid=<%=userid%>">换乘查询</a></li>
            <li><a href="searchrecord.jsp">我的订单</a></li>
            <li><a href="permission_request_list.jsp?uid=<%=userid%>">权限代理</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">换乘查询</h1>
        <p class="page-subtitle">查询需要换乘的车次信息</p>
        
        <div class="card fade-in">
            <h2 class="card-title">换乘查询</h2>
            <form id="indexform" name="indexForm" action="huanzhengcheck.jsp?uid=<%=userid%>" method="post" accept-charset="utf-8">
                <div class="form-group">
                    <label class="form-label" for="origin">出发地</label>
                    <div class="form-input-wrapper location">
                        <input type="text" id="origin" name="origin" class="form-input" placeholder="请输入出发城市" required autocomplete="off">
                    </div>
                    <div id="origin-suggestions" class="suggestions" style="display: none;"></div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="destination">目的地</label>
                    <div class="form-input-wrapper location">
                        <input type="text" id="destination" name="destination" class="form-input" placeholder="请输入目的城市" required autocomplete="off">
                    </div>
                    <div id="destination-suggestions" class="suggestions" style="display: none;"></div>
                </div>
                <div class="form-group">
                    <label class="form-label" for="depart_date">出发日期</label>
                    <div class="form-input-wrapper calendar">
                        <input type="date" id="depart_date" name="depart_date" class="form-input" required>
                        <input type="hidden" id="year" name="year">
                        <input type="hidden" id="month" name="month">
                        <input type="hidden" id="day" name="day">
                    </div>
                </div>
                <div class="btn-group">
                    <button type="submit" class="btn btn-primary btn-block">查询换乘车次</button>
                </div>
            </form>
        </div>
        
        <div class="card fade-in" style="margin-top: 2rem;">
            <h2 class="card-title">换乘说明</h2>
            <p style="color: var(--text-secondary); line-height: 1.8;">
                换乘查询将为您找到需要在中途站点换乘的车次组合。系统会自动匹配第一段和第二段车次，确保换乘时间合理。
            </p>
        </div>
    
    <style>
        .suggestions {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(10px);
            border: 2px solid var(--accent-blue);
            border-top: none;
            border-radius: 0 0 8px 8px;
            box-shadow: var(--shadow-lg);
            z-index: 1000;
            max-height: 200px;
            overflow-y: auto;
            margin-top: -2px;
        }
        .suggestions-item {
            padding: 0.75rem 1rem;
            cursor: pointer;
            transition: var(--transition-fast);
            border-bottom: 1px solid var(--light-gray);
        }
        .suggestions-item:hover {
            background: rgba(61, 143, 194, 0.1);
        }
        .suggestions-item:last-child {
            border-bottom: none;
        }
        
        /* 日历选择器样式 */
        input[type="date"] {
            width: 100%;
            padding: 0.875rem 1rem;
            font-size: 1rem;
            border: 2px solid var(--border);
            border-radius: 8px;
            background: var(--bg-input);
            color: var(--text-primary);
            transition: var(--transition);
            cursor: pointer;
        }
        
        input[type="date"]:focus {
            outline: none;
            border-color: var(--crimson);
            background: var(--bg-input-focus);
            box-shadow: 0 0 0 3px rgba(139, 46, 46, 0.1);
        }
        
        input[type="date"]::-webkit-calendar-picker-indicator {
            cursor: pointer;
            opacity: 0.6;
            filter: invert(0.3);
        }
        
        input[type="date"]::-webkit-calendar-picker-indicator:hover {
            opacity: 1;
        }
    </style>
    
    <script>
        // 常用城市列表
        const cities = ['咸阳','雍城','大梁','邯郸','新郑','临淄','蓟','郢','寿春'];
        
        // 城市搜索建议
        function setupCitySuggestions(inputId, suggestionsId) {
            const input = document.getElementById(inputId);
            const suggestions = document.getElementById(suggestionsId);
            
            input.addEventListener('input', function() {
                const value = this.value.trim();
                if (value.length > 0) {
                    const matches = cities.filter(city => city.includes(value));
                    if (matches.length > 0) {
                        suggestions.innerHTML = matches.map(city => 
                            `<div class="suggestions-item" onclick="selectCity('${inputId}', '${city}')">${city}</div>`
                        ).join('');
                        suggestions.style.display = 'block';
                    } else {
                        suggestions.style.display = 'none';
                    }
                } else {
                    suggestions.style.display = 'none';
                }
            });
            
            input.addEventListener('blur', function() {
                setTimeout(() => suggestions.style.display = 'none', 200);
            });
        }
        
        function selectCity(inputId, city) {
            document.getElementById(inputId).value = city;
            document.getElementById(inputId + '-suggestions').style.display = 'none';
        }
        
        setupCitySuggestions('origin', 'origin-suggestions');
        setupCitySuggestions('destination', 'destination-suggestions');
        
        // 日期选择器设置和转换
        window.addEventListener('DOMContentLoaded', function() {
            const dateInput = document.getElementById('depart_date');
            const yearInput = document.getElementById('year');
            const monthInput = document.getElementById('month');
            const dayInput = document.getElementById('day');
            
            // 设置最小日期为今天
            const today = new Date();
            const minDate = today.toISOString().split('T')[0];
            dateInput.setAttribute('min', minDate);
            
            // 设置默认值为今天
            dateInput.value = minDate;
            
            // 初始化隐藏字段
            const dateParts = minDate.split('-');
            yearInput.value = dateParts[0];
            monthInput.value = dateParts[1];
            dayInput.value = dateParts[2];
            
            // 当日期改变时，更新隐藏字段
            dateInput.addEventListener('change', function() {
                const selectedDate = this.value;
                if(selectedDate) {
                    const parts = selectedDate.split('-');
                    yearInput.value = parts[0];
                    monthInput.value = parts[1];
                    dayInput.value = parts[2];
                }
            });
        });
    </script>
    </div>
</body>
</html>

