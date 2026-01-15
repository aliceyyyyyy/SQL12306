<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/11/30
  Time: 14:23
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.sql.*,java.io.*,java.util.*"%>
<%@ page contentType="text/html;charset=utf-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 车次列表</title>
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
        String userid = request.getParameter("uid");
        if(userid == null) {
            userid = (String)session.getAttribute("user_id");
        }
        if(userid == null) userid = "";
        String homeLink = userid != null && !userid.isEmpty() ? "loginsuccess.jsp?message=" + userid : "loginsuccess.jsp";
    %>
    <nav class="navbar">
        <a href="<%=homeLink%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="<%=homeLink%>">首页</a></li>
            <li><a href="chepiaochaxun.jsp?uid=<%=userid%>">车票查询</a></li>
            <li><a href="tuipiao.jsp">退票</a></li>
            <li><a href="gaipiao.jsp?uid=<%=userid%>">改签</a></li>
            <li><a href="searchrecord.jsp">我的订单</a></li>
            <li><a href="view_trainlist.jsp?uid=<%=userid%>">车次列表</a></li>
            <li><a href="permission_request_list.jsp?uid=<%=userid%>">权限代理</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">
        <h1 class="page-title">车次信息</h1>
        <p class="page-subtitle">所有可用车次列表</p>
    <%
        // 搜索参数
        String searchKeyword = request.getParameter("search");
        if(searchKeyword == null) searchKeyword = "";
        searchKeyword = searchKeyword.trim();
        
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
        // 如果有搜索关键词，重置到第一页
        if(!searchKeyword.isEmpty() && pageParam == null) {
            currentPage = 1;
        }
        int offset = (currentPage - 1) * pageSize;
        
        try {
            //驱动程序名
            String driverName = "com.mysql.jdbc.Driver";
            //数据库用户名
            String userName = "root";
            //密码
            String userPasswd = "bei060805";

            //联结字符串
            String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
            Connection connection = DriverManager.getConnection(url,userName,userPasswd);
            Statement stmt = connection.createStatement();
            
            // 构建搜索条件
            String whereClause = "";
            if(!searchKeyword.isEmpty()) {
                whereClause = " WHERE trainnum LIKE '%" + searchKeyword + "%' OR origin LIKE '%" + searchKeyword + "%' OR destination LIKE '%" + searchKeyword + "%'";
            }
            
            // 获取总记录数
            String countSql = "SELECT COUNT(*) as total FROM train" + whereClause;
            ResultSet countRs = stmt.executeQuery(countSql);
            int totalRecords = 0;
            if(countRs.next()) {
                totalRecords = countRs.getInt("total");
            }
            countRs.close();
            
            // 计算总页数
            int totalPages = (int)Math.ceil((double)totalRecords / pageSize);
            if(totalPages == 0) totalPages = 1;
            if(currentPage > totalPages) currentPage = totalPages;
            
            // 分页查询（直接查询train表，不使用存储过程以支持分页）
            String sql = "SELECT trainnum, origin, destination, maxmem, normalprice FROM train" + whereClause + " ORDER BY trainnum LIMIT " + pageSize + " OFFSET " + offset;
            ResultSet rs = stmt.executeQuery(sql);
    %>
        <div class="card" style="max-width: 100%; margin-bottom: 2rem;">
            <form method="GET" action="view_trainlist.jsp" style="display: flex; gap: 1rem; align-items: center; margin-bottom: 1.5rem;">
                <input type="hidden" name="uid" value="<%=userid%>">
                <div class="form-input-wrapper" style="flex: 1; max-width: 400px;">
                    <input type="text" name="search" class="form-input" placeholder="搜索车次号、出发地或目的地..." value="<%=searchKeyword%>">
                </div>
                <button type="submit" class="btn btn-primary">搜索</button>
                <% if(!searchKeyword.isEmpty()) { %>
                <a href="view_trainlist.jsp?uid=<%=userid%>" class="btn btn-secondary">清除</a>
                <% } %>
            </form>
        </div>
        
        <div class="card" style="max-width: 100%;">
            <div class="data-table-wrapper">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>车次号</th>
                            <th>出发地</th>
                            <th>目的地</th>
                            <th>总座位数</th>
                            <th>基础价格（元）</th>
                        </tr>
                    </thead>
                    <tbody>
        <%
            int count = 0;
            while (rs.next()) {
                count++;
                String trainnum = rs.getString("trainnum");
                String origin = rs.getString("origin");
                String destination = rs.getString("destination");
                String maxmem = rs.getString("maxmem");
                String normalprice = rs.getString("normalprice");
        %>
                        <tr>
                            <td><strong><%out.print(trainnum);%></strong></td>
                            <td><%out.print(origin);%></td>
                            <td><%out.print(destination);%></td>
                            <td><%out.print(maxmem);%> 座</td>
                            <td><strong style="color: var(--accent-color);">¥<%out.print(normalprice);%></strong></td>
                        </tr>
        <%
            }
            if (count == 0) {
        %>
                        <tr>
                            <td colspan="5" class="empty-state">
                                <div class="empty-state-title">暂无车次信息</div>
                            </td>
                        </tr>
        <%
            }
            rs.close();
            stmt.close();
            connection.close();
        %>
                    </tbody>
                </table>
            </div>
            
            <%-- 分页导航 --%>
            <div style="display: flex; justify-content: center; align-items: center; gap: 1rem; margin-top: 2rem; padding: 1rem;">
                <%
                    String pageLinkPrefix = "view_trainlist.jsp?";
                    if(userid != null && !userid.isEmpty()) {
                        pageLinkPrefix += "uid=" + userid + "&";
                    }
                    if(!searchKeyword.isEmpty()) {
                        pageLinkPrefix += "search=" + java.net.URLEncoder.encode(searchKeyword, "UTF-8") + "&";
                    }
                    
                    if(currentPage > 1) {
                %>
                    <a href="<%=pageLinkPrefix%>page=<%=currentPage - 1%>" class="btn btn-secondary">上一页</a>
                <%
                    } else {
                %>
                    <span class="btn btn-secondary" style="opacity: 0.5; cursor: not-allowed;">上一页</span>
                <%
                    }
                %>
                
                <span style="color: var(--text-secondary);">
                    第 <%=currentPage%> 页 / 共 <%=totalPages%> 页（共 <%=totalRecords%> 条记录）
                    <% if(!searchKeyword.isEmpty()) { %>
                    <span style="color: var(--crimson);">（搜索：<%=searchKeyword%>）</span>
                    <% } %>
                </span>
                
                <%
                    if(currentPage < totalPages) {
                %>
                    <a href="<%=pageLinkPrefix%>page=<%=currentPage + 1%>" class="btn btn-secondary">下一页</a>
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

