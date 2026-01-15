<%@ page language="java" import="java.sql.Connection,
java.sql.DriverManager,
java.sql.Statement,
java.sql.ResultSet,
java.sql.SQLException,
java.sql.CallableStatement,
java.io.FileInputStream,
java.io.FileNotFoundException,
java.io.FileOutputStream,
java.io.IOException,
java.util.Random,
java.io.File ,
java.io.Writer,
java.io.FileWriter ,
java.sql.*" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%request.setCharacterEncoding("utf-8");%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>列国驿轨系统 高速铁路 - 购票</title>
    <link rel="stylesheet" href="css/main.css">
    <style>

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
    <nav class="navbar">
        <%
            String uuid = request.getParameter("uid");
            if(uuid == null) {
                uuid = (String)session.getAttribute("user_id");
            }
            if(uuid == null) uuid = "";
            String homeLink = uuid != null && !uuid.isEmpty() ? "loginsuccess.jsp?message=" + uuid : "loginsuccess.jsp";
        %>
        <a href="<%=homeLink%>" class="logo">列国驿轨系统</a>
        <ul class="nav-links">
            <li><a href="<%=homeLink%>">首页</a></li>
            <li><a href="chepiaochaxun.jsp?uid=<%=uuid%>">车票查询</a></li>
            <li><a href="tuipiao.jsp">退票</a></li>
            <li><a href="gaipiao.jsp?uid=<%=uuid%>">改签</a></li>
            <li><a href="searchrecord.jsp">我的订单</a></li>
            <li><a href="view_trainlist.jsp?uid=<%=uuid%>">车次列表</a></li>
            <li><a href="permission_request_list.jsp?uid=<%=uuid%>">权限代理</a></li>
            <li><a href="login.jsp">退出登录</a></li>
        </ul>
    </nav>
    
    <div class="container">

<%

    request.setCharacterEncoding("utf-8");
    // uuid已在导航栏部分声明，这里不再重复声明
    if(uuid == null) {
        uuid = request.getParameter("uid");
    }
    String tn=request.getParameter("trainnum");
    String tim=request.getParameter("time");
    String seatType=request.getParameter("seatType"); // 座位类型参数
    String trainType=request.getParameter("trainType"); // 车型参数
    String o=request.getParameter("o");
    String d=request.getParameter("d");
    String p=request.getParameter("p");
    // 用户选择的座位（如果还未选择，则为null）
    String selectedSeat = request.getParameter("seatnum");
    boolean seatChosen = selectedSeat != null && !selectedSeat.isEmpty();
    String tickt="";
    String jsMessage = null; // 用于存储JavaScript消息
    System.out.println("开始");
    //out.print(tim);
    //out.print("<center><h1 color='red' size='20'>你好，world2！</h1></center>");
    try {
        // 加载数据库驱动，注册到驱动管理器
        Class.forName("com.mysql.jdbc.Driver");
        // 数据库连接字符串
        String url = "jdbc:mysql://localhost:3306/wanli_12306?serverTimezone=UTC";
        // 数据库用户名
        String usename = "root";
        // 数据库密码
        String psw = "bei060805";
        // 创建Connection连接
        Connection conn = DriverManager.getConnection(url,usename,psw);
        // 判断 数据库连接是否为空
        if(conn != null){
            Statement stmt = conn.createStatement();
            
            // 检查库存和车次信息
            String sql1="select trip.nowmem,trip.trainnum from trip where trainnum='"+tn+"' and time='"+ tim + "'";
            ResultSet rs1=stmt.executeQuery(sql1);
// 将内容输出，保存文件
// 第4步、关闭输出流
            //out.print(rs1.getString(1));
            if(rs1.next()){
                if(rs1.getString(1).equals("0")) {
                    out.println("<div class='card fade-in' style='max-width: 100%;'>");
                    out.println("<div class='alert alert-error'><strong>购票失败</strong> 当前车次暂无余票，请选择其他车次</div>");
                    out.println("<div class='text-center mt-3'>");
                    out.println("<a href='loginsuccess.jsp?message="+uuid+"' class='btn btn-primary'>返回查询</a>");
                    out.println("</div>");
                    out.println("</div>");
                }
                else{
                    // 如果还没有选择具体座位，先展示可选座位列表
                    if(!seatChosen) {
                        // 查询所有可用座位（seat表中sit=0的座位）
                        String seatSql = "SELECT seatnum FROM seat WHERE trainnum='" + tn + "' AND time='" + tim + "' AND sit=0 ORDER BY seatnum";
                        ResultSet seatRs = stmt.executeQuery(seatSql);
                        java.util.List<String> freeSeats = new java.util.ArrayList<String>();
                        while(seatRs.next()) {
                            freeSeats.add(seatRs.getString(1));
                        }
                        seatRs.close();
                        
                        if(freeSeats.isEmpty()) {
                            out.println("<div class='card fade-in' style='max-width: 100%;'>");
                            out.println("<div class='alert alert-error'><strong>购票失败</strong> 当前车次暂无可用座位，请选择其他车次</div>");
                            out.println("<div class='text-center mt-3'>");
                            out.println("<a href='chepiaochaxun.jsp?uid="+uuid+"' class='btn btn-primary'>返回查询</a>");
                            out.println("</div>");
                            out.println("</div>");
                            conn.close();
                            return;
                        }
                        
                        // 展示座位选择页面
                        out.println("<div class='card fade-in' style='max-width: 100%;'>");
                        out.println("<h2 class='card-title'>请选择座位</h2>");
                        out.println("<p class='page-subtitle' style='margin-bottom: 1.5rem;'>当前车次：" + tn + "，" + o + " → " + d + "，发车时间：" + tim + "</p>");
                        out.println("<form method='post' action='buying.jsp'>");
                        // 保留原有参数
                        out.println("<input type='hidden' name='trainnum' value='" + tn + "'/>");
                        out.println("<input type='hidden' name='time' value='" + tim + "'/>");
                        out.println("<input type='hidden' name='o' value='" + o + "'/>");
                        out.println("<input type='hidden' name='d' value='" + d + "'/>");
                        out.println("<input type='hidden' name='p' value='" + p + "'/>");
                        out.println("<input type='hidden' name='uid' value='" + uuid + "'/>");
                        
                        out.println("<div class='form-group'>");
                        out.println("<label class='form-label' for='seatnum'>可选座位</label>");
                        out.println("<div class='form-input-wrapper'>");
                        out.println("<select id='seatnum' name='seatnum' class='form-input' required>");
                        out.println("<option value='' disabled selected>请选择一个未被占用的座位</option>");
                        for(String s : freeSeats) {
                            out.println("<option value='" + s + "'>" + s + " 座</option>");
                        }
                        out.println("</select>");
                        out.println("</div>");
                        out.println("</div>");
                        out.println("<div class='btn-group'>");
                        out.println("<button type='submit' class='btn btn-primary'>确认座位并购票</button>");
                        out.println("<a href='chepiaochaxun.jsp?uid="+uuid+"' class='btn btn-secondary'>返回重新选择车次</a>");
                        out.println("</div>");
                        out.println("</form>");
                        out.println("</div>");
                        
                        conn.close();
                        return;
                    }
                    
                    // 已选择具体座位，验证该座位是否仍然空闲
                    String checkSeatSql = "SELECT sit FROM seat WHERE trainnum='" + tn + "' AND time='" + tim + "' AND seatnum='" + selectedSeat + "'";
                    ResultSet seatCheckRs = stmt.executeQuery(checkSeatSql);
                    if(!seatCheckRs.next() || seatCheckRs.getInt(1) != 0) {
                        seatCheckRs.close();
                        out.println("<div class='card fade-in' style='max-width: 100%;'>");
                        out.println("<div class='alert alert-error'><strong>购票失败</strong> 您选择的座位已被占用，请重新选择座位</div>");
                        out.println("<div class='text-center mt-3'>");
                        out.println("<a href='chepiaochaxun.jsp?uid="+uuid+"' class='btn btn-primary'>返回查询</a>");
                        out.println("</div>");
                        out.println("</div>");
                        conn.close();
                        return;
                    }
                    seatCheckRs.close();
                    
                    // 生成车票号
                    String str="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                    Random random=new Random();
                    StringBuffer sb=new StringBuffer();
                    for(int i=0;i<9;i++){
                        int number=random.nextInt(35);
                        sb.append(str.charAt(number));
                    }
                    String nextp=sb.toString();
                    tickt="T" + nextp; // 车票号格式：T + 9位随机字符
                    
                    // 使用用户选择的座位号
                    String sn = selectedSeat;
                    
                    // 调用CREATE_TICKET存储过程（5个参数：ticketnum, seatnum, trainnum, time, id）
                    CallableStatement cstmt = conn.prepareCall( "{call CREATE_TICKET(?,?,?,?,?)}" );
                    cstmt.setString( 1 ,tickt);
                    cstmt.setString( 2 ,sn);
                    cstmt.setString( 3 ,tn);
                    cstmt.setString( 4 ,tim);
                    cstmt.setString( 5 ,uuid);
                    cstmt.execute();
                    
                    System.out.println("购票成功: ticketnum=" + tickt + ", seatnum=" + sn + ", trainnum=" + tn + ", time=" + tim + ", uid=" + uuid);
                    //=String.valueOf(System.currentTimeMillis());
                    //CallableStatement cstmt2 = conn.prepareCall( "{call CREATE_PCR(?,?)}" );
                   // cstmt2.setString( 1 ,uid);
                    // 计算车厢号（根据座位号，每60个座位一个车厢）
                    int chexiang = 1;
                    try {
                        int seatNum = Integer.parseInt(sn);
                        chexiang = 1 + (seatNum - 1) / 60;
                    } catch(Exception e) {
                        chexiang = 1;
                    }
                    
                    String sql5="select name from user where id='"+uuid+"'";
                    ResultSet rs5=stmt.executeQuery(sql5);
                    String nam="";
                    if(rs5.next()){
                       nam=rs5.getString(1);
                    }
                    out.println("<div class='card fade-in' style='max-width: 100%;'>");
                    out.println("<div class='alert alert-success'><span class='train-icon'>🚄</span> <strong>购买成功！</strong> 您的车票已确认，请妥善保管以下信息</div>");
                    out.println("<h2 class='card-title'>电子车票</h2>");
                    out.println("<div class='ticket-card'>");
                    out.println("<div style='display: grid; grid-template-columns: 2fr 1fr; gap: 2rem; margin-bottom: 1.5rem;'>");
                    out.println("<div>");
                    out.println("<div style='font-size: 1.25rem; font-weight: 700; color: var(--text-primary); margin-bottom: 1rem;'>"+tn+"</div>");
                    out.println("<div style='display: grid; grid-template-columns: repeat(2, 1fr); gap: 1rem;'>");
                    out.println("<div><div class='ticket-info-label'>出发站</div><div class='ticket-info-value' style='font-size: 1.25rem;'>"+o+"</div></div>");
                    out.println("<div><div class='ticket-info-label'>到达站</div><div class='ticket-info-value' style='font-size: 1.25rem;'>"+d+"</div></div>");
                    out.println("<div><div class='ticket-info-label'>发车时间</div><div class='ticket-info-value' style='font-size: 1.1rem;'>"+tim+"</div></div>");
                    out.println("<div><div class='ticket-info-label'>座位信息</div><div class='ticket-info-value' style='font-size: 1.1rem;'>"+chexiang+"车厢 "+sn+"座</div></div>");
                    out.println("</div>");
                    out.println("</div>");
                    out.println("<div class='ticket-qr'>");
                    out.println("<div class='qr-placeholder'>");
                    out.println("<div style='text-align: center;'>");
                    out.println("<div style='font-size: 2rem; margin-bottom: 0.5rem;'>📱</div>");
                    out.println("<div>二维码</div>");
                    out.println("<div style='font-size: 0.75rem; color: var(--text-secondary); margin-top: 0.5rem;'>"+tickt+"</div>");
                    out.println("</div>");
                    out.println("</div>");
                    out.println("</div>");
                    out.println("</div>");
                    out.println("<div style='border-top: 2px dashed var(--border-color); padding-top: 1.5rem; margin-top: 1.5rem;'>");
                    out.println("<div class='ticket-info' style='grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));'>");
                    out.println("<div class='ticket-info-item'><div class='ticket-info-label'>车票编号</div><div class='ticket-info-value' style='font-size: 1rem;'>"+tickt+"</div></div>");
                    out.println("<div class='ticket-info-item'><div class='ticket-info-label'>乘客姓名</div><div class='ticket-info-value' style='font-size: 1rem;'>"+nam+"</div></div>");
                    out.println("<div class='ticket-info-item'><div class='ticket-info-label'>身份证号</div><div class='ticket-info-value' style='font-size: 0.875rem; word-break: break-all;'>"+uuid+"</div></div>");
                    out.println("<div class='ticket-info-item'><div class='ticket-info-label'>票价</div><div class='ticket-info-value' style='color: var(--rail-red); font-size: 1.25rem;'>¥"+p+"</div></div>");
                    out.println("</div>");
                    out.println("</div>");
                    out.println("</div>");
                    // 转义JavaScript字符串中的特殊字符（双引号、反斜杠、换行符等）
                    String safeTickt = (tickt != null ? tickt : "").replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                    String safeTn = (tn != null ? tn : "").replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                    String safeO = (o != null ? o : "").replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                    String safeD = (d != null ? d : "").replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                    String safeTim = (tim != null ? tim : "").replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                    String safeSn = (sn != null ? sn : "").replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
                    
                    // 构建JavaScript消息字符串（在输出script标签之前完成）
                    StringBuilder jsMsg = new StringBuilder();
                    jsMsg.append("车票编号: ").append(safeTickt);
                    jsMsg.append("\\n车次: ").append(safeTn);
                    jsMsg.append("\\n出发: ").append(safeO);
                    jsMsg.append(" → ").append(safeD);
                    jsMsg.append("\\n时间: ").append(safeTim);
                    jsMsg.append("\\n座位: ").append(chexiang).append("车厢").append(safeSn).append("座");
                    jsMessage = jsMsg.toString(); // 保存到页面作用域变量
                    
                    out.println("<div class='flex-center gap-2 mt-3' style='flex-wrap: wrap;'>");
                    out.println("<button onclick='window.print()' class='btn btn-secondary'>打印车票</button>");
                    out.println("<button onclick='shareTicket()' class='btn btn-outline'>分享车票</button>");
                    out.println("<a href='loginsuccess.jsp?message="+uuid+"' class='btn btn-primary'>返回首页</a>");
                    out.println("</div>");
                    out.println("</div>");

                }
                //response.sendRedirect("loginsuccess.jsp");
            }else{
                out.println("<div class='card fade-in' style='max-width: 100%;'>");
                out.println("<div class='alert alert-error'><strong>错误</strong> 无法获取车次信息</div>");
                out.println("<div class='text-center mt-3'>");
                out.println("<a href='loginsuccess.jsp' class='btn btn-primary'>返回首页</a>");
                out.println("</div>");
                out.println("</div>");
            }
            // 输出连接信息
            //out.println("数据库连接成功！");
            // 关闭数据库连接

            conn.close();
        }else{
                    out.println("<div class='card fade-in' style='max-width: 100%;'>");
            out.println("<div class='alert alert-error'><strong>系统错误</strong> 数据库连接失败，请稍后重试</div>");
            out.println("</div>");
        }
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<% if (jsMessage != null) { %>
<script type="text/javascript">
function shareTicket() {
    var msg = "<%=jsMessage%>";
    alert(msg);
}
</script>
<% } %>
    </div>
</body>
</html>