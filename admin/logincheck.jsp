<%--
  列国驿轨系统 高速铁路 - 管理员登录验证
  根据账号判断权限并跳转到相应管理页面
--%>
<%@ page language="java" import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>管理员登录验证</title>
    <link rel="stylesheet" href="../css/main.css">
</head>
<body>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    if(username == null || password == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    try {
        // 根据账号判断权限
        String role = "";
        String dbUser = "";
        String dbPassword = "";
        
        // 判断管理员类型
        if("user_admin".equals(username)) {
            role = "user_admin";
            dbUser = "user_admin";
            dbPassword = "123456";
        } else if("train_admin".equals(username)) {
            role = "train_admin";
            dbUser = "train_admin";
            dbPassword = "123456";
        } else if("root".equals(username)) {
            role = "super_admin";
            dbUser = "root";
            dbPassword = "bei060805";
        } else {
            // 尝试使用app_user账号（普通用户）
            role = "normal_user";
            dbUser = "app_user";
            dbPassword = "123456";
        }
        
        // 验证密码
        if(!"123456".equals(password) && !"bei060805".equals(password)) {
            out.println("<div class='container'><div class='card'><div class='alert alert-error'>密码错误！</div><a href='login.jsp' class='btn btn-primary'>返回登录</a></div></div>");
            return;
        }
        
        // 测试数据库连接（使用对应权限的账号）
        Class.forName("com.mysql.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8";
        Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);
        
        if(conn != null) {
            conn.close();
            
            // 根据角色跳转到相应页面
            session.setAttribute("admin_username", username);
            session.setAttribute("admin_role", role);
            
            if("user_admin".equals(role)) {
                response.sendRedirect("user_admin.jsp");
            } else if("train_admin".equals(role)) {
                response.sendRedirect("train_admin.jsp");
            } else if("super_admin".equals(role)) {
                response.sendRedirect("super_admin.jsp");
            } else {
                response.sendRedirect("../loginsuccess.jsp?message=" + username);
            }
        } else {
            out.println("<div class='container'><div class='card'><div class='alert alert-error'>数据库连接失败！</div><a href='login.jsp' class='btn btn-primary'>返回登录</a></div></div>");
        }
    } catch(Exception e) {
        e.printStackTrace();
        out.println("<div class='container'><div class='card'><div class='alert alert-error'>登录失败：" + e.getMessage() + "</div><a href='login.jsp' class='btn btn-primary'>返回登录</a></div></div>");
    }
%>
</body>
</html>


