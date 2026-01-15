<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/12/1
  Time: 13:57
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 改签</title>
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
    <nav class="navbar">
        <%
            String userid = request.getParameter("uid");
            if(userid == null) {
                userid = (String)session.getAttribute("user_id");
            }
            if(userid == null) userid = "";
            String ticketnum = request.getParameter("ticket");
            String homeLink = userid != null && !userid.isEmpty() ? "loginsuccess.jsp?message=" + userid : "loginsuccess.jsp";
        %>
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
        <h1 class="page-title">车票改签</h1>
        <p class="page-subtitle">请输入相关信息以完成改签操作</p>
        
        <div class="card fade-in" style="max-width: 100%;">
            <h2 class="card-title">改签验证</h2>
            <form id="indexform" name="indexForm" action="gaipiaocheck.jsp" method="post">
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
                    <label class="form-label" for="ticket">待改签车票号</label>
                    <div class="form-input-wrapper ticket">
                        <input type="text" id="ticket" name="ticket" class="form-input" value="<%=ticketnum != null ? ticketnum : ""%>" placeholder="请输入车票编号（字母+数字组合）" required pattern="[A-Za-z0-9]+" oninput="validateTicket(this)" <%if(ticketnum != null) {%>readonly<%}%>>
                    </div>
                    <small id="ticket-hint" style="display: none; color: var(--rail-red); font-size: 0.875rem; margin-top: 0.25rem;">车票号格式不正确，应为字母和数字组合</small>
                    <% if(ticketnum != null) { %>
                    <small style="color: var(--text-secondary); font-size: 0.875rem; margin-top: 0.25rem;">已从订单选择，不可修改</small>
                    <% } %>
                </div>
                <div class="form-group">
                    <label class="form-label" for="new_train">新车次</label>
                    <div class="form-input-wrapper">
                        <select id="new_train" name="new_train" class="form-input" required>
                            <option value="">请选择车次</option>
                            <%
                                try {
                                    Class.forName("com.mysql.jdbc.Driver");
                                    String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
                                    Connection conn = DriverManager.getConnection(url, "root", "bei060805");
                                    Statement stmt = conn.createStatement();
                                    ResultSet rs = stmt.executeQuery("SELECT DISTINCT trainnum FROM train ORDER BY trainnum");
                                    while(rs.next()) {
                                        String tn = rs.getString("trainnum");
                            %>
                            <option value="<%=tn%>"><%=tn%></option>
                            <%
                                    }
                                    conn.close();
                                } catch(Exception e) {
                                    // 忽略错误，显示空选项
                                }
                            %>
                        </select>
                    </div>
                    <small style="color: var(--text-secondary); font-size: 0.875rem; margin-top: 0.25rem;">请先选择车次，然后选择发车时间</small>
                </div>
                <div class="form-group">
                    <label class="form-label" for="new_time">新车次发车时间</label>
                    <div class="form-input-wrapper">
                        <input type="datetime-local" id="new_time" name="new_time" class="form-input" required>
                    </div>
                    <small id="time-hint" style="display: none; color: var(--rail-red); font-size: 0.875rem; margin-top: 0.25rem;">请选择未来的日期和时间</small>
                </div>
                <div class="alert alert-warning">
                    <strong>改签须知：</strong> 改签将收取手续费，差价将根据新票价格多退少补
                </div>
                <div class="btn-group">
                    <button type="submit" class="btn btn-primary btn-block" onclick="return confirmChange(event)">确认改签</button>
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
        
        function confirmChange(event) {
            const ticket = document.getElementById('ticket').value.trim();
            const newTrain = document.getElementById('new_train').value.trim();
            const newTime = document.getElementById('new_time').value.trim();
            
            if (!ticket || !newTrain || !newTime) {
                alert('请填写完整信息');
                event.preventDefault();
                return false;
            }
            
            if (!validateTicket(document.getElementById('ticket'))) {
                event.preventDefault();
                return false;
            }
            
            // 检查时间是否为未来时间
            const selectedTime = new Date(newTime);
            const now = new Date();
            if (selectedTime <= now) {
                document.getElementById('time-hint').style.display = 'block';
                event.preventDefault();
                return false;
            }
            
            const confirmMsg = '确认改签？\n\n' +
                '原车票号：' + ticket + '\n' +
                '新车次：' + newTrain + '\n' +
                '新发车时间：' + newTime + '\n' +
                '手续费：按票价的10%收取\n' +
                '差价：多退少补\n\n' +
                '确定要继续吗？';
            
            if (!confirm(confirmMsg)) {
                event.preventDefault();
                return false;
            }
            
            return true;
        }
        
        // 设置日期时间选择器的最小值为当前时间
        window.addEventListener('DOMContentLoaded', function() {
            const timeInput = document.getElementById('new_time');
            const now = new Date();
            // 设置最小值为当前时间（格式：YYYY-MM-DDTHH:MM）
            const minDateTime = now.toISOString().slice(0, 16);
            timeInput.setAttribute('min', minDateTime);
            
            // 设置默认值为明天 08:00
            const tomorrow = new Date(now);
            tomorrow.setDate(tomorrow.getDate() + 1);
            tomorrow.setHours(8, 0, 0, 0);
            const defaultDateTime = tomorrow.toISOString().slice(0, 16);
            timeInput.value = defaultDateTime;
        });
    </script>
        </div>
    </div>
</body>
</html>

