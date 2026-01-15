<%--
  Created by IntelliJ IDEA.
  User: Alienware
  Date: 2020/11/23
  Time: 21:51
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" import="java.sql.Connection,
java.sql.DriverManager,
java.sql.Statement,
java.sql.ResultSet,
java.sql.SQLException,
java.sql.PreparedStatement,
java.util.Random,
java.io.File ,
java.io.Writer,
java.io.FileWriter ,
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
    String username=request.getParameter("userid");
    String uname=request.getParameter("name");
    String upassword=request.getParameter("password");
    String ugender=request.getParameter("gender");
    String uphone=request.getParameter("phone");
    String uid_type=request.getParameter("id_type");
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
            // 检查手机号是否已存在
            Statement checkStmt = conn.createStatement();
            ResultSet phoneCheck = checkStmt.executeQuery("SELECT id FROM user WHERE phone='" + uphone + "'");
            if(phoneCheck.next()) {
                response.sendRedirect("zhucefail.jsp?reason=手机号已被注册");
                conn.close();
                return;
            }
            
            // 使用新的字段插入用户（包含手机号、证件类型、实名验证状态）
            String insertSql = "INSERT INTO user (id, name, password, gender, phone, id_type, real_name_verified) VALUES (?, ?, ?, ?, ?, ?, 1)";
            PreparedStatement pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, username);
            pstmt.setString(2, uname);
            pstmt.setString(3, upassword);
            pstmt.setString(4, ugender);
            pstmt.setString(5, uphone);
            pstmt.setString(6, uid_type != null ? uid_type : "身份证");
            
            // 如果存在NEW_user存储过程，也可以使用，但需要先检查存储过程是否支持新字段
            // 这里直接使用INSERT语句更灵活
            long startTime = System.currentTimeMillis();
            pstmt.executeUpdate();
            long endTime = System.currentTimeMillis();
            long tim=endTime-startTime;
            
            // 记录注册时间
            File f = new File("d:" + File.separator + "Userregister_timerecord.txt");
            Writer outter = null;
            try {
                outter = new FileWriter(f, true);
                String strr = "User: " + uname + " register success " + "usingtime: " + tim + " ms\r\n";
                outter.write(strr);
                outter.close();
            } catch (Exception e) {
                if (outter != null) {
                    try {
                        outter.close();
                    } catch (Exception ex) {
                    }
                }
            }
            
            // 验证插入是否成功
            Statement stmt = conn.createStatement();
            String sql = "select * from user where id='" + username + "'";
            ResultSet rs = stmt.executeQuery(sql);
            if (rs.next()) {
                response.sendRedirect("zhucesuccess.jsp");
            } else {
                response.sendRedirect("zhucefail.jsp");
            }
            rs.close();
            // 输出连接信息
            //out.println("数据库连接成功！");
            // 关闭数据库连接
            conn.close();
            stmt.close();
            pstmt.close();
            checkStmt.close();
        }
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
</body>

</html>