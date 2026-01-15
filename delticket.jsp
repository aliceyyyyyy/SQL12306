<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/12/1
  Time: 16:44
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.sql.Connection,
java.sql.DriverManager,
java.sql.Statement,
java.sql.ResultSet,
java.sql.SQLException,
java.util.Random,
java.sql.*" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>身份验证</title>
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
    </style>
</head>
<body>
    <video class="video-background" autoplay muted loop playsinline preload="auto">
        <source src="Star_Rail_Wallpaper.mp4" type="video/mp4">
    </video>
<%
    String uid=request.getParameter("userid");
    String upassword=request.getParameter("password");
    String ticket=request.getParameter("ticketnum");
    out.println("开始");
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
        // 判断 数据库连接是否为空
        if(conn != null){
            CallableStatement cstmt = conn.prepareCall( "{call DELETE_purchaserecord(?,?)}" );
            cstmt.setString( 1 ,uid);
            cstmt.setString( 2 ,ticket);
            String sql="select * from ticket where id='"+ticket+"'";
            Statement stmt = conn.createStatement();
            ResultSet rs1=stmt.executeQuery(sql);
            if(!rs1.next()){
                response.sendRedirect("tuipiao.jsp");
            }
            else{
                cstmt.execute();
                ResultSet rs=stmt.executeQuery(sql);
                if(rs.next()){
                    response.sendRedirect("zhucesuccess.jsp");
                }else{
                    response.sendRedirect("zhucefail.jsp");
%>
< a href=" "></ a>
<%
                }
                // 输出连接信息
                //out.println("数据库连接成功！");
                // 关闭数据库连接
                conn.close();
                stmt.close();
                cstmt.close();
            }}else{
            // 输出连接信息
            out.println("数据库连接失败！");
        }
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
</body>

</html>