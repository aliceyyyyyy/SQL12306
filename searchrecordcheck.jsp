<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/12/1
  Time: 15:08
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.sql.*,java.io.*,java.util.*"%>
<%@ page contentType="text/html;charset=utf-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 我的订单</title>
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
    </style>
</head>
<body>
    <video class="video-background" autoplay muted loop playsinline preload="auto">
        <source src="Star_Rail_Wallpaper.mp4" type="video/mp4">
    </video>
    <%
        String uid = request.getParameter("id");
        if(uid == null) {
            uid = (String)session.getAttribute("user_id");
        }
        if(uid == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        session.setAttribute("user_id", uid);
        String homeLink = "loginsuccess.jsp?message=" + uid;
    %>
    <nav class="navbar">
        <a href="<%=homeLink%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="<%=homeLink%>">首页</a></li>
            <li><a href="chepiaochaxun.jsp?uid=<%=uid%>">车票查询</a></li>
            <li><a href="tuipiao.jsp">退票</a></li>
            <li><a href="gaipiao.jsp?uid=<%=uid%>">改签</a></li>
            <li><a href="searchrecord.jsp">我的订单</a></li>
            <li><a href="view_trainlist.jsp?uid=<%=uid%>">车次列表</a></li>
            <li><a href="permission_request_list.jsp?uid=<%=uid%>">权限代理</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">我的订单</h1>
        <p class="page-subtitle">您的购票记录</p>
    <%
        // 分页参数
        int pageSize = 10;
        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if(pageParam != null && !pageParam.isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
                if(currentPage < 1) currentPage = 1;
            } catch(Exception e) {
                currentPage = 1;
            }
        }
        int offset = (currentPage - 1) * pageSize;
        
        try {
            // 加载数据库驱动，注册到驱动管理器
            Class.forName("com.mysql.jdbc.Driver");
            // 数据库连接字符串
            String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
            // 数据库用户名
            String usename = "root";
            // 数据库密码
            String psw = "bei060805";
            // 创建Connection连接
            Connection conn = DriverManager.getConnection(url,usename,psw);
            // 直接查询ticket表
            Statement stmt = conn.createStatement();
            
            // 获取总记录数
            ResultSet countRs = stmt.executeQuery("SELECT COUNT(*) as total FROM ticket WHERE id='" + uid + "'");
            int totalRecords = 0;
            if(countRs.next()) {
                totalRecords = countRs.getInt("total");
            }
            countRs.close();
            
            // 计算总页数
            int totalPages = (int)Math.ceil((double)totalRecords / pageSize);
            if(totalPages == 0) totalPages = 1;
            if(currentPage > totalPages) currentPage = totalPages;
            
            // 分页查询
            String sql = "SELECT ticketnum, seatnum, trainnum, time, id FROM ticket WHERE id='" + uid + "' ORDER BY time DESC LIMIT " + pageSize + " OFFSET " + offset;
            ResultSet rs = stmt.executeQuery(sql);
    %>
        <div class="card" style="max-width: 100%;">
            <div class="data-table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>车票编号</th>
                            <th>座位号</th>
                            <th>车次</th>
                            <th>发车时间</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
            <%
                int count = 0;
                while (rs.next()) {
                    count++;
                    String ticketnum = rs.getString(1);
                    String seatnum = rs.getString(2);
                    String trainnum = rs.getString(3);
                    String time = rs.getString(4);
                    String userId = rs.getString(5);
            %>
                        <tr>
                            <td class="highlight"><strong><%out.print(ticketnum);%></strong></td>
                            <td><%out.print(seatnum);%></td>
                            <td class="highlight"><%out.print(trainnum);%></td>
                            <td><%out.print(time);%></td>
                            <td>
                                <a href="tuipiao.jsp?ticket=<%=ticketnum%>&uid=<%=uid%>" class="link" style="color: var(--danger); margin-right: 1rem;">退票</a>
                                <a href="gaipiao.jsp?ticket=<%=ticketnum%>&uid=<%=uid%>" class="link link-primary">改签</a>
                            </td>
                        </tr>
            <%
                }
                if (count == 0) {
            %>
                        <tr>
                            <td colspan="5" class="empty-state">
                                <div class="empty-state-icon">🎫</div>
                                <div class="empty-state-title">暂无购票记录</div>
                                <p>您还没有购买过车票</p>
                            </td>
                        </tr>
            <%
                }
                rs.close();
                stmt.close();
                conn.close();
            %>
                    </tbody>
                </table>
            </div>
            
            <%-- 分页导航 --%>
            <div style="display: flex; justify-content: center; align-items: center; gap: 1rem; margin-top: 2rem; padding: 1rem;">
                <%
                    if(currentPage > 1) {
                %>
                    <a href="searchrecordcheck.jsp?page=<%=currentPage - 1%>&id=<%=uid%>" class="btn btn-secondary">上一页</a>
                <%
                    } else {
                %>
                    <span class="btn btn-secondary" style="opacity: 0.5; cursor: not-allowed;">上一页</span>
                <%
                    }
                %>
                
                <span style="color: var(--text-secondary);">
                    第 <%=currentPage%> 页 / 共 <%=totalPages%> 页（共 <%=totalRecords%> 条记录）
                </span>
                
                <%
                    if(currentPage < totalPages) {
                %>
                    <a href="searchrecordcheck.jsp?page=<%=currentPage + 1%>&id=<%=uid%>" class="btn btn-secondary">下一页</a>
                <%
                    } else {
                %>
                    <span class="btn btn-secondary" style="opacity: 0.5; cursor: not-allowed;">下一页</span>
                <%
                    }
                %>
            </div>
        </div>
    <%
        } catch(Exception e) {
            out.println("<div class='alert alert-error'>加载失败：" + e.getMessage() + "</div>");
        }
    %>
    </div>
</body>
</html>
