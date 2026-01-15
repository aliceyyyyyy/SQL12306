CREATE DATABASE wanli_12306;
    USE wanli_12306;
    
    -- 用户表
    CREATE TABLE user (
      id VARCHAR(45) PRIMARY KEY,
      name VARCHAR(45) NOT NULL,
      password VARCHAR(45) NOT NULL,
      gender VARCHAR(10) NOT NULL
    );
    
    -- 车次表
    CREATE TABLE train (
      trainnum VARCHAR(45) PRIMARY KEY,
      origin VARCHAR(45) NOT NULL,
      destination VARCHAR(45) NOT NULL,
      maxmem INT NOT NULL,
      normalprice FLOAT NOT NULL
    );
    
    -- 车次运行表
    CREATE TABLE trip (
      trainnum VARCHAR(45),
      time VARCHAR(45),
      nowmem INT NOT NULL,
      nowprice FLOAT NOT NULL,
      PRIMARY KEY (trainnum, time),
      FOREIGN KEY (trainnum) REFERENCES train(trainnum)
    );
    
    -- 座位表
    CREATE TABLE seat (
      seatnum VARCHAR(45),
      trainnum VARCHAR(45),
      time VARCHAR(45),
      sit INT NOT NULL DEFAULT 0,
      PRIMARY KEY (seatnum, trainnum, time)
    );
    
    -- 车票表（补充用户 id）
    CREATE TABLE ticket (
      ticketnum VARCHAR(45) PRIMARY KEY,
      seatnum VARCHAR(45),
      trainnum VARCHAR(45),
      time VARCHAR(45),
      id VARCHAR(45)
    );
    
    ALTER TABLE ticket
    ADD FOREIGN KEY (seatnum) REFERENCES seat(seatnum),
    ADD FOREIGN KEY (id) REFERENCES user(id);
    
    
     CREATE VIEW trian_dongche AS
    SELECT
      trainnum,
      origin,
      destination,
      maxmem
    FROM train
    WHERE trainnum LIKE 'D%';
    
    CREATE VIEW trip_dongche AS
    SELECT
      t.trainnum,
      tr.origin,
      tr.destination,
      t.time,
      t.nowprice
    FROM trip t
    JOIN train tr ON t.trainnum = tr.trainnum
    WHERE t.trainnum LIKE 'D%';
    
        ALTER TABLE user ADD INDEX idx_name(name);
    ALTER TABLE seat ADD INDEX idx_sit(sit);
    ALTER TABLE seat ADD INDEX idx_seatnum(seatnum);
    ALTER TABLE ticket ADD INDEX idx_userid(id);
    -- 补充train表出发地/目的地索引
    ALTER TABLE train
    ADD INDEX idx_origin (origin) USING BTREE,
    ADD INDEX idx_destination (destination) USING BTREE;
    
    
  
    -- 触发器1：车票表(ticket)触发器 维护购票/退票的座位+余票联动
    DELIMITER $$
    CREATE TRIGGER ticket_AFTER_INSERT
    -- 向ticket车票表，插入数据之后执行，即用户购票成功后触发
    AFTER INSERT ON ticket
    FOR EACH ROW 
    BEGIN
      -- 将seat座位表中，匹配的座位，状态改为1（1=已售出）
      UPDATE seat
      SET sit = 1
      WHERE seatnum = NEW.seatnum  
        AND trainnum = NEW.trainnum
        AND time = NEW.time;
      -- 更新对应车次的剩余票数-1
      -- 将trip车次运行表中，匹配当前车次号、发车时间的车次，剩余座位数减1
      UPDATE trip
      SET nowmem = nowmem - 1
      WHERE trainnum = NEW.trainnum
        AND time = NEW.time;
    END$$  
    
    CREATE TRIGGER ticket_BEFORE_DELETE
    -- 向ticket车票表，删除数据之前执行，即用户退票操作时触发
    BEFORE DELETE ON ticket
    FOR EACH ROW 
    BEGIN
      -- 将seat座位表中，匹配的座位，状态改为0（0=空闲/未售出）
      UPDATE seat
      SET sit = 0
      WHERE seatnum = OLD.seatnum   
        AND trainnum = OLD.trainnum
        AND time = OLD.time;
    
      -- 更新对应车次的剩余票数+1
      -- 将trip车次运行表中，匹配当前车次号、发车时间的车次，剩余座位数加1
      UPDATE trip
      SET nowmem = nowmem + 1
      WHERE trainnum = OLD.trainnum
        AND time = OLD.time;
    END$$
    
    DELIMITER ;
    
    -- 触发器2：车次运行表(trip)触发器 维护车次与座位的联动
    DELIMITER $$
    CREATE TRIGGER trip_AFTER_INSERT
    -- 新增车次运行班次时触发
    AFTER INSERT ON trip
    FOR EACH ROW  
    BEGIN
      -- x 用于循环生成座位号，初始值为1
      DECLARE x INT DEFAULT 1;
      -- num 用于存储当前车次的最大载客量
      DECLARE num INT;
      -- seat_number 用于存储3位座位号
      DECLARE seat_number VARCHAR(45);
    
      -- 将当前新增车次的最大载客量，赋值给变量num
      SELECT maxmem INTO num FROM train WHERE trainnum = NEW.trainnum;
    
      -- 循环生成座位
      WHILE x <= num DO
        
        SET seat_number = LPAD(x, 3, '0');
        -- 向seat座位表中插入生成的座位数据
        INSERT INTO seat(seatnum, trainnum, time, sit)
        VALUES (seat_number, NEW.trainnum, NEW.time, 0);
        SET x = x + 1;
      END WHILE;
    END$$
    
    -- 触发时机：向trip车次运行表 删除数据之前 执行（删除车次运行班次时触发）
    CREATE TRIGGER trip_BEFORE_DELETE
    BEFORE DELETE ON trip
    FOR EACH ROW  -- 行级触发器：每删除1个车次班次，就执行1次触发器逻辑
    BEGIN
      -- 核心逻辑：级联删除seat座位表中，当前删除车次对应的所有座位数据
      -- 避免出现【车次已删除、座位数据残留】的脏数据问题
      DELETE FROM seat
      WHERE trainnum = OLD.trainnum AND time = OLD.time;
    END$$
    
    
    DELIMITER ;
    

    DELIMITER $$
    
    -- 创建触发器：user_BEFORE_UPDATE
    -- 触发时机：向user用户表 更新数据之前 执行（用户修改ID时触发）
    CREATE TRIGGER user_BEFORE_UPDATE
    BEFORE UPDATE ON user
    FOR EACH ROW  -- 行级触发器：每修改1条用户数据，就执行1次触发器逻辑
    BEGIN
      -- 核心逻辑：同步更新ticket车票表中，该用户的所有车票记录的用户ID
      -- 保证【用户ID变更后，车票与用户的关联关系不中断】，外键关联一致性
      UPDATE ticket SET id = NEW.id WHERE id = OLD.id;
    END$$
    

    DELIMITER ;
  
  
  
  
    DELIMITER $$
    -- 创建购票存储过程：传入车票号、座位号、车次号、发车时间、用户ID，执行购票插入
    CREATE PROCEDURE CREATE_TICKET(
      IN tic VARCHAR(45), 
      IN sn VARCHAR(45),  
      IN tn VARCHAR(45), 
      IN ti VARCHAR(45),  
      IN uid VARCHAR(45)   
    )
    BEGIN
      INSERT INTO ticket VALUES (tic, sn, tn, ti, uid);
      -- 插入购票信息到车票表，购票后触发车票触发器自动扣减余票、占用座位
    END$$
    
    -- 创建退票存储过程：传入用户ID、车票号，精准删除该用户对应车票
    CREATE PROCEDURE DELETE_ticket(
      IN uid VARCHAR(45), 
      IN tnum VARCHAR(45)  
    )
    BEGIN
      DELETE FROM ticket WHERE ticketnum = tnum AND id = uid; 
      -- 删除后触发触发器释放座位、恢复余票
    END$$
    
    -- 创建用户注册存储过程
    CREATE PROCEDURE NEW_user(
      IN uid VARCHAR(45),    
      IN uname VARCHAR(45), 
      IN upassword VARCHAR(45), 
      IN ugender VARCHAR(45) 
    )
    BEGIN
      INSERT INTO user VALUES (uid, uname, upassword, ugender); 
      -- 插入新用户数据到用户表
    END$$
    
    -- 创建查询购票记录存储过程
    CREATE PROCEDURE purchaseRecordsearch(IN sid VARCHAR(45)) 
    BEGIN
      SELECT t.ticketnum, t.trainnum, t.time, t.seatnum, tr.nowprice
      FROM ticket t
       -- 关联车票表和车次运行表
      JOIN trip tr ON t.trainnum = tr.trainnum AND t.time = tr.time 
      WHERE t.id = sid; -- 筛选当前用户的购票记录
    END$$
    
    -- 创建查询可购票车次存储过程
    CREATE PROCEDURE SEARCH_TRIP_BUY(IN o VARCHAR(45), IN d VARCHAR(45)) 
    BEGIN
      SELECT tr.trainnum, tr.origin, tr.destination, t.time, t.nowprice
      FROM train tr
      JOIN trip t ON tr.trainnum = t.trainnum -- 关联车次基础表和车次运行表，关联车次编号
      WHERE tr.origin = o AND tr.destination = d; -- 筛选指定起止地的车次
    END$$
    
    -- 创建查询所有车次存储过程
    CREATE PROCEDURE trainLIST()
    BEGIN
      SELECT * FROM train; 
    END$$
    
    -- 创建修改用户密码存储过程
    CREATE PROCEDURE UPDATE_user_password(IN uid VARCHAR(45), IN upass VARCHAR(45)) 
    BEGIN
      UPDATE user SET password = upass WHERE id = uid; -- 修改指定用户的密码
    END$$
    
    DELIMITER ;
    
    
  -- 设计数据库角色
  
  
    USE wanli_12306;
    -- 根据关系模型的外键，添加外键约束
    -- ticket表补充外键约束
    -- 改为适配中文
    ALTER DATABASE wanli_12306 
    CHARACTER SET = utf8mb4 
    COLLATE = utf8mb4_0900_ai_ci;
    -- 修改 user 表
    ALTER TABLE user 
    CONVERT TO CHARACTER SET utf8mb4 
    COLLATE utf8mb4_0900_ai_ci;
    -- 修改 train 表
    ALTER TABLE train 
    CONVERT TO CHARACTER SET utf8mb4 
    COLLATE utf8mb4_0900_ai_ci;
    -- 修改 trip 表
    ALTER TABLE trip 
    CONVERT TO CHARACTER SET utf8mb4 
    COLLATE utf8mb4_0900_ai_ci;
    -- 修改 seat 表
    ALTER TABLE seat 
    CONVERT TO CHARACTER SET utf8mb4 
    COLLATE utf8mb4_0900_ai_ci;
    -- 修改 ticket 表
    ALTER TABLE ticket 
    CONVERT TO CHARACTER SET utf8mb4 
    COLLATE utf8mb4_0900_ai_ci;
    -- 修改字段类型
    ALTER TABLE trip MODIFY time DATETIME;
    ALTER TABLE ticket MODIFY time DATETIME;
    ALTER TABLE seat MODIFY time DATETIME;
    
    
    
  
    -- DROP USER IF EXISTS 'app_user'@'%';
    -- 创建角色
    CREATE ROLE Normal_user;
    CREATE ROLE User_admini;
    CREATE ROLE Train_admini;
    GRANT INSERT ON TABLE user To Normal_user;
    GRANT SELECT ON TABLE train To Normal_user;
    GRANT SELECT,UPDATE,INSERT ON TABLE user To User_admini;
    GRANT SELECT ON TABLE ticket To User_admini;
    GRANT SELECT ON TABLE trip To User_admini;
    GRANT SELECT ON TABLE train To User_admini;
    GRANT SELECT ON TABLE seat To User_admini;
    GRANT SELECT,INSERT, UPDATE,delete ON TABLE ticket To Train_admini;
    GRANT SELECT,INSERT, UPDATE,delete ON TABLE train To Train_admini;
    
    
    
    
  
    CREATE USER 'app_user'@'%' IDENTIFIED BY '123456';
    CREATE USER 'user_admin'@'%' IDENTIFIED BY '123456';
    CREATE USER 'train_admin'@'%' IDENTIFIED BY '123456';
    
    
    
  
    GRANT SELECT ON wanli_12306.train TO Normal_user;
    GRANT SELECT, INSERT ON wanli_12306.ticket TO Normal_user;
    
    GRANT SELECT, UPDATE ON wanli_12306.user TO User_admini;
    GRANT SELECT ON wanli_12306.ticket TO User_admini;
    
    
    GRANT SELECT, INSERT, UPDATE, DELETE ON wanli_12306.train TO Train_admini;
    GRANT SELECT, INSERT, UPDATE, DELETE ON wanli_12306.trip TO Train_admini;
    GRANT Normal_user TO 'app_user'@'%';
    GRANT User_admini TO 'user_admin'@'%';
    GRANT Train_admini TO 'train_admin'@'%';
    
    

    -- 激活所有角色，让权限立即生效
    SET DEFAULT ROLE ALL TO
    `Normal_user`@`%`, 
    `User_admini`@`%`, 
    `Train_admini`@`%`;
    -- 验证权限：查看普通用户角色的权限是否正确
    SHOW GRANTS FOR `Normal_user`@`%`;
    -- 激活权限
    SET DEFAULT ROLE ALL TO
    'app_user'@'%',
    'user_admin'@'%',
    'train_admin'@'%';
    
    -- 批量生成存储过程
  
    DELIMITER $$
    
    -- 删除原有存储过程（避免冲突）
    DROP PROCEDURE IF EXISTS generate_users;
    
    -- 新建存储过程：中文姓名 + 随机密码
    CREATE PROCEDURE generate_users()
    BEGIN
      -- 变量声明（显式指定utf8mb4字符集，避免编码问题）
      DECLARE i INT DEFAULT 1;
      DECLARE uid VARCHAR(45) CHARACTER SET utf8mb4;
      DECLARE uname VARCHAR(45) CHARACTER SET utf8mb4;
      DECLARE ugender VARCHAR(10) CHARACTER SET utf8mb4;
      DECLARE upassword VARCHAR(45) CHARACTER SET utf8mb4; -- 存储随机密码
      DECLARE pwd_length INT; -- 密码长度（8-12位随机）
      DECLARE pwd_char VARCHAR(100) DEFAULT 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; -- 密码字符池
      DECLARE pwd_index INT; -- 随机字符索引
    
      WHILE i <= 2000 DO
        -- 1. 生成用户ID（U0001~U2000）
        SET uid = CONCAT('U', LPAD(i, 4, '0'));
    
        -- 2. 生成随机中文姓名（1个姓氏 + 1~2个名字）
        SET uname = CONCAT(
          ELT(FLOOR(1 + RAND()*15), '赵','钱','孙','李','周','吴','郑','王','刘','陈','杨','黄','林','张','胡'),
          ELT(FLOOR(1 + RAND()*20), '明','华','伟','芳','娜','强','敏','静','磊','军','丽','娟','涛','洋','杰','婷','浩','燕','峰','刚'),
          IF(RAND() > 0.5, ELT(FLOOR(1 + RAND()*20), '明','华','伟','芳','娜','强','敏','静','磊','军','丽','娟','涛','洋','杰','婷','浩','燕','峰','刚'), '')
        );
    
        -- 3. 生成随机性别
        SET ugender = IF(RAND() > 0.5, '男', '女');
    
        -- 4. 生成随机密码（8-12位，含大小写字母+数字）
        SET pwd_length = FLOOR(8 + RAND()*5); -- 8~12位（5是因为12-8+1=5，RAND()*5取0~4.999，加8后是8~12）
        SET upassword = ''; -- 初始化密码为空字符串
        WHILE LENGTH(upassword) < pwd_length DO
          -- 从字符池随机选1个字符（字符池长度62：26大写+26小写+10数字）
          SET pwd_index = FLOOR(1 + RAND()*LENGTH(pwd_char));
          SET upassword = CONCAT(upassword, SUBSTRING(pwd_char, pwd_index, 1));
        END WHILE;
    
        -- 5. 插入用户数据（中文姓名+随机密码）
        INSERT INTO user(id, name, password, gender)
        VALUES (uid, uname, upassword, ugender);
    
        SET i = i + 1;
      END WHILE;
    END$$
    
    DELIMITER ;
    
  
    
    DROP PROCEDURE IF EXISTS generate_trains;
    USE wanli_12306;
    DELIMITER $$
    CREATE PROCEDURE generate_trains()
    BEGIN
      DECLARE i INT DEFAULT 1;
      DECLARE o VARCHAR(20);
      DECLARE d VARCHAR(20);
    
      WHILE i <= 1000 DO
    
        -- 随机起点
        SET o = ELT(FLOOR(1 + RAND()*8),
          '咸阳','雍城','大梁','邯郸','新郑','临淄','蓟','郢');
    
        -- 随机终点（先给一个）
        SET d = ELT(FLOOR(1 + RAND()*8),
          '咸阳','雍城','大梁','邯郸','新郑','临淄','蓟','郢');
    
    
        WHILE d = o DO
          SET d = ELT(FLOOR(1 + RAND()*8),
            '咸阳','雍城','大梁','邯郸','新郑','临淄','蓟','郢');
        END WHILE;
    
        INSERT INTO train VALUES (
          CONCAT(
            ELT(FLOOR(1 + RAND()*3),'G','D','C'),
            LPAD(i,4,'0')
          ),
          o,
          d,
          IF(RAND()>0.7,300,IF(RAND()>0.4,200,100)),
          IF(RAND()>0.7,600 + RAND()*200,300 + RAND()*200)
        );
    
        SET i = i + 1;
      END WHILE;
    END$$
    
    DELIMITER ;
    
    
    
  
    DELIMITER $$
    
    CREATE PROCEDURE gen_ticket()
    BEGIN
      DECLARE i INT DEFAULT 1;
      DECLARE uid VARCHAR(20);
      DECLARE tnum VARCHAR(20);
      DECLARE ttime DATETIME;
      DECLARE s VARCHAR(10);
    
      WHILE i <= 20000 DO
        SELECT id INTO uid FROM user ORDER BY RAND() LIMIT 1;
    
        SELECT trainnum, time INTO tnum, ttime
        FROM trip
        WHERE nowmem > 0
        ORDER BY RAND()
        LIMIT 1;
    
        SELECT seatnum INTO s
        FROM seat
        WHERE trainnum = tnum AND time = ttime AND sit = 0
        LIMIT 1;
    
        IF s IS NOT NULL THEN
          INSERT INTO ticket VALUES (
            CONCAT('T', UUID_SHORT()),
            s, tnum, ttime, uid
          );
        END IF;
    
        SET i = i + 1;
      END WHILE;
    END$$
    DELIMITER ;
    
    
    
    
  
    DELIMITER $$
    CREATE PROCEDURE generate_trips()
    BEGIN
      DECLARE done INT DEFAULT 0;
      DECLARE tnum VARCHAR(45);
      DECLARE mem INT;
      DECLARE price FLOAT;
      DECLARE d INT;
      DECLARE cur CURSOR FOR SELECT trainnum, maxmem, normalprice FROM train;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
      OPEN cur;
      read_loop: LOOP
        FETCH cur INTO tnum, mem, price;
        IF done THEN LEAVE read_loop; END IF;
    
        -- 生成过去15天到未来15天的数据（共31天）
        SET d = -7;  -- 从15天前开始
        
        WHILE d <= 15 DO  -- 到15天后结束
          -- 上午班次 (8:00)
          INSERT INTO trip VALUES
          (tnum, 
           DATE_ADD(CURDATE(), INTERVAL d DAY) + INTERVAL 8 HOUR, 
           mem,  -- 初始剩余座位数 = 最大座位数
           price);
          
          -- 下午班次 (16:00)
          INSERT INTO trip VALUES
          (tnum, 
           DATE_ADD(CURDATE(), INTERVAL d DAY) + INTERVAL 16 HOUR, 
           mem,  -- 初始剩余座位数 = 最大座位数
           price + 30);
          
          SET d = d + 1;
        END WHILE;
      END LOOP;
      CLOSE cur;
    END$$
    DELIMITER ;
    
    
    
    
    -- 调用存储过程生成数据（按顺序）
    CALL generate_trains();     -- 生成车次
    CALL generate_trips();      -- 生成行程（包含历史数据）
    CALL generate_users();      -- 生成用户
    CALL gen_ticket();          -- 生成车票
  
  
  
  
  
  
  
  
  
  
    -- 改签
    DELIMITER $$
    
    CREATE PROCEDURE CHANGE_TICKET(
        IN old_ticket VARCHAR(45),
        IN new_train VARCHAR(45),
        IN new_time VARCHAR(45)
    )
    BEGIN
        DECLARE uid VARCHAR(45);
        DECLARE s VARCHAR(45);
    
        -- 查用户
        SELECT id INTO uid FROM ticket WHERE ticketnum = old_ticket;
    
        -- 找新座位
        SELECT seatnum INTO s
        FROM seat
        WHERE trainnum = new_train
          AND time = new_time
          AND sit = 0
        LIMIT 1;
    
        IF s IS NOT NULL THEN
            -- 退旧票
            DELETE FROM ticket WHERE ticketnum = old_ticket;
    
            -- 买新票
            INSERT INTO ticket VALUES (
                CONCAT('T',UUID_SHORT()),
                s,
                new_train,
                new_time,
                uid
            );
        END IF;
    END$$
    
    DELIMITER ;
    
    
    -- 退票
    DELIMITER $$
    
    CREATE PROCEDURE REFUND_TICKET(
        IN p_ticketnum VARCHAR(45)
    )
    BEGIN
        DECLARE t_train VARCHAR(45);
        DECLARE t_time VARCHAR(45);
        DECLARE t_seat VARCHAR(45);
    
        -- 取票信息
        SELECT trainnum, time, seatnum
        INTO t_train, t_time, t_seat
        FROM ticket
        WHERE ticketnum = p_ticketnum;
    
        -- 未发车才允许退
        IF t_time > NOW() THEN
            DELETE FROM ticket WHERE ticketnum = p_ticketnum;
            -- seat & trip 由 BEFORE DELETE 触发器自动恢复
        END IF;
    END$$
    
    DELIMITER ;
    
    -- 直达查询
    DELIMITER $$
    
    CREATE PROCEDURE SEARCH_DIRECT(
        IN p_origin VARCHAR(45),
        IN p_dest VARCHAR(45),
        IN p_date VARCHAR(10)
    )
    BEGIN
        SELECT
            tr.trainnum,
            tr.origin,
            tr.destination,
            t.time,
            t.nowprice,
            t.nowmem
        FROM train tr
        JOIN trip t ON tr.trainnum = t.trainnum
        WHERE tr.origin = p_origin
          AND tr.destination = p_dest
          AND DATE(t.time) = p_date
          AND t.nowmem > 0
        ORDER BY t.time;
    END$$
    
    DELIMITER ;
    
    -- 换乘
    DELIMITER $$
    
    CREATE PROCEDURE SEARCH_TRANSFER(
        IN p_origin VARCHAR(45),
        IN p_dest VARCHAR(45),
        IN p_date VARCHAR(10)
    )
    BEGIN
        SELECT
            a.trainnum AS first_train,
            a.origin,
            a.destination AS transfer_station,
            t1.time AS first_depart,
            b.trainnum AS second_train,
            b.destination,
            t2.time AS second_depart,
            (t1.nowprice + t2.nowprice) AS total_price
        FROM train a
        JOIN train b ON a.destination = b.origin
        JOIN trip t1 ON a.trainnum = t1.trainnum
        JOIN trip t2 ON b.trainnum = t2.trainnum
        WHERE a.origin = p_origin
          AND b.destination = p_dest
          AND DATE(t1.time) = p_date
          AND DATE(t2.time) = p_date
          AND t1.time < t2.time
          AND t1.nowmem > 0
          AND t2.nowmem > 0
        ORDER BY t1.time
        LIMIT 20;
    END$$
    
    DELIMITER ;
    
    
    
    
  
    USE wanli_12306;
    
    -- 1. 车次列表搜索存储过程
    DROP PROCEDURE IF EXISTS SEARCH_TRAIN_LIST;
    DELIMITER $$
    CREATE PROCEDURE SEARCH_TRAIN_LIST(
        IN p_search_keyword VARCHAR(100),
        IN p_page_size INT,
        IN p_offset INT
    )
    BEGIN
        DECLARE v_where_clause VARCHAR(500);
        
        -- 构建WHERE子句
        IF p_search_keyword IS NULL OR p_search_keyword = '' THEN
            SET v_where_clause = '';
        ELSE
            SET v_where_clause = CONCAT(' WHERE trainnum LIKE ''%', p_search_keyword, '%'' OR origin LIKE ''%', p_search_keyword, '%'' OR destination LIKE ''%', p_search_keyword, '%''');
        END IF;
        
        -- 执行查询
        SET @sql = CONCAT('SELECT trainnum, origin, destination, maxmem, normalprice FROM train', v_where_clause, ' ORDER BY trainnum LIMIT ', p_page_size, ' OFFSET ', p_offset);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
    DELIMITER ;
    
    
    -- 2. 用户管理搜索存储过程
    DROP PROCEDURE IF EXISTS SEARCH_USER_MANAGE;
    DELIMITER $$
    CREATE PROCEDURE SEARCH_USER_MANAGE(
        IN p_search_keyword VARCHAR(100),
        IN p_page_size INT,
        IN p_offset INT
    )
    BEGIN
        DECLARE v_where_clause VARCHAR(500);
        
        -- 构建WHERE子句
        IF p_search_keyword IS NULL OR p_search_keyword = '' THEN
            SET v_where_clause = '';
        ELSE
            SET v_where_clause = CONCAT(' WHERE id LIKE ''%', p_search_keyword, '%'' OR name LIKE ''%', p_search_keyword, '%''');
        END IF;
        
        -- 执行查询
        SET @sql = CONCAT('SELECT id, name, gender FROM user', v_where_clause, ' ORDER BY id LIMIT ', p_page_size, ' OFFSET ', p_offset);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
    DELIMITER ;
    
    
    -- 3. 车次管理搜索存储过程
    DROP PROCEDURE IF EXISTS SEARCH_TRAIN_MANAGE;
    DELIMITER $$
    CREATE PROCEDURE SEARCH_TRAIN_MANAGE(
        IN p_search_keyword VARCHAR(100),
        IN p_page_size INT,
        IN p_offset INT
    )
    BEGIN
        DECLARE v_where_clause VARCHAR(500);
        
        -- 构建WHERE子句
        IF p_search_keyword IS NULL OR p_search_keyword = '' THEN
            SET v_where_clause = '';
        ELSE
            SET v_where_clause = CONCAT(' WHERE trainnum LIKE ''%', p_search_keyword, '%'' OR origin LIKE ''%', p_search_keyword, '%'' OR destination LIKE ''%', p_search_keyword, '%''');
        END IF;
        
        -- 执行查询
        SET @sql = CONCAT('SELECT trainnum, origin, destination, maxmem, normalprice FROM train', v_where_clause, ' ORDER BY trainnum LIMIT ', p_page_size, ' OFFSET ', p_offset);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
    DELIMITER ;
    
    
    -- 4. 运行班次管理搜索存储过程
    DROP PROCEDURE IF EXISTS SEARCH_TRIP_MANAGE;
    DELIMITER $$
    CREATE PROCEDURE SEARCH_TRIP_MANAGE(
        IN p_search_keyword VARCHAR(100),
        IN p_page_size INT,
        IN p_offset INT
    )
    BEGIN
        DECLARE v_where_clause VARCHAR(500);
        
        -- 构建WHERE子句
        IF p_search_keyword IS NULL OR p_search_keyword = '' THEN
            SET v_where_clause = '';
        ELSE
            SET v_where_clause = CONCAT(' WHERE trainnum LIKE ''%', p_search_keyword, '%'' OR time LIKE ''%', p_search_keyword, '%''');
        END IF;
        
        -- 执行查询
        SET @sql = CONCAT('SELECT trainnum, time, nowmem, nowprice FROM trip', v_where_clause, ' ORDER BY time DESC LIMIT ', p_page_size, ' OFFSET ', p_offset);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
    DELIMITER ;
    
    
    -- 5. 车票管理搜索存储过程
    DROP PROCEDURE IF EXISTS SEARCH_TICKET_MANAGE;
    DELIMITER $$
    CREATE PROCEDURE SEARCH_TICKET_MANAGE(
        IN p_search_keyword VARCHAR(100),
        IN p_page_size INT,
        IN p_offset INT
    )
    BEGIN
        DECLARE v_where_clause VARCHAR(500);
        
        -- 构建WHERE子句
        IF p_search_keyword IS NULL OR p_search_keyword = '' THEN
            SET v_where_clause = '';
        ELSE
            SET v_where_clause = CONCAT(' WHERE ticketnum LIKE ''%', p_search_keyword, '%'' OR id LIKE ''%', p_search_keyword, '%'' OR trainnum LIKE ''%', p_search_keyword, '%'' OR seatnum LIKE ''%', p_search_keyword, '%''');
        END IF;
        
        -- 执行查询
        SET @sql = CONCAT('SELECT ticketnum, id, seatnum, trainnum, time FROM ticket', v_where_clause, ' ORDER BY time DESC LIMIT ', p_page_size, ' OFFSET ', p_offset);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
    DELIMITER ;
    
    
    -- 6. 权限代理搜索存储过程
    DROP PROCEDURE IF EXISTS SEARCH_PERMISSION_REQUEST;
    DELIMITER $$
    CREATE PROCEDURE SEARCH_PERMISSION_REQUEST(
        IN p_user_id VARCHAR(45),
        IN p_search_keyword VARCHAR(100)
    )
    BEGIN
        DECLARE v_where_clause VARCHAR(500);
        
        -- 构建WHERE子句
        SET v_where_clause = CONCAT(' WHERE user_id = ''', p_user_id, '''');
        
        IF p_search_keyword IS NOT NULL AND p_search_keyword != '' THEN
            SET v_where_clause = CONCAT(v_where_clause, ' AND (request_id LIKE ''%', p_search_keyword, '%'' OR request_title LIKE ''%', p_search_keyword, '%'' OR request_type LIKE ''%', p_search_keyword, '%'')');
        END IF;
        
        -- 执行查询
        SET @sql = CONCAT('SELECT * FROM permission_request', v_where_clause, ' ORDER BY create_time DESC');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
    DELIMITER ;
    
    
    -- 7. 获取搜索结果总数的存储过程
    -- 车次列表总数
    DROP PROCEDURE IF EXISTS COUNT_TRAIN_LIST;
    DELIMITER $$
    CREATE PROCEDURE COUNT_TRAIN_LIST(
        IN p_search_keyword VARCHAR(100)
    )
    BEGIN
        DECLARE v_where_clause VARCHAR(500);
        
        IF p_search_keyword IS NULL OR p_search_keyword = '' THEN
            SET v_where_clause = '';
        ELSE
            SET v_where_clause = CONCAT(' WHERE trainnum LIKE ''%', p_search_keyword, '%'' OR origin LIKE ''%', p_search_keyword, '%'' OR destination LIKE ''%', p_search_keyword, '%''');
        END IF;
        
        SET @sql = CONCAT('SELECT COUNT(*) AS total FROM train', v_where_clause);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
    DELIMITER ;
    
    -- 用户管理总数
    DROP PROCEDURE IF EXISTS COUNT_USER_MANAGE;
    DELIMITER $$
    CREATE PROCEDURE COUNT_USER_MANAGE(
        IN p_search_keyword VARCHAR(100)
    )
    BEGIN
        DECLARE v_where_clause VARCHAR(500);
        
        IF p_search_keyword IS NULL OR p_search_keyword = '' THEN
            SET v_where_clause = '';
        ELSE
            SET v_where_clause = CONCAT(' WHERE id LIKE ''%', p_search_keyword, '%'' OR name LIKE ''%', p_search_keyword, '%''');
        END IF;
        
        SET @sql = CONCAT('SELECT COUNT(*) AS total FROM user', v_where_clause);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
    DELIMITER ;
    
    -- 车次管理总数
    DROP PROCEDURE IF EXISTS COUNT_TRAIN_MANAGE;
    DELIMITER $$
    CREATE PROCEDURE COUNT_TRAIN_MANAGE(
        IN p_search_keyword VARCHAR(100)
    )
    BEGIN
        DECLARE v_where_clause VARCHAR(500);
        
        IF p_search_keyword IS NULL OR p_search_keyword = '' THEN
            SET v_where_clause = '';
        ELSE
            SET v_where_clause = CONCAT(' WHERE trainnum LIKE ''%', p_search_keyword, '%'' OR origin LIKE ''%', p_search_keyword, '%'' OR destination LIKE ''%', p_search_keyword, '%''');
        END IF;
        
        SET @sql = CONCAT('SELECT COUNT(*) AS total FROM train', v_where_clause);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
    DELIMITER ;
    
    -- 运行班次管理总数
    DROP PROCEDURE IF EXISTS COUNT_TRIP_MANAGE;
    DELIMITER $$
    CREATE PROCEDURE COUNT_TRIP_MANAGE(
        IN p_search_keyword VARCHAR(100)
    )
    BEGIN
        DECLARE v_where_clause VARCHAR(500);
        
        IF p_search_keyword IS NULL OR p_search_keyword = '' THEN
            SET v_where_clause = '';
        ELSE
            SET v_where_clause = CONCAT(' WHERE trainnum LIKE ''%', p_search_keyword, '%'' OR time LIKE ''%', p_search_keyword, '%''');
        END IF;
        
        SET @sql = CONCAT('SELECT COUNT(*) AS total FROM trip', v_where_clause);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
    DELIMITER ;
    
    -- 车票管理总数
    DROP PROCEDURE IF EXISTS COUNT_TICKET_MANAGE;
    DELIMITER $$
    CREATE PROCEDURE COUNT_TICKET_MANAGE(
        IN p_search_keyword VARCHAR(100)
    )
    BEGIN
        DECLARE v_where_clause VARCHAR(500);
        
        IF p_search_keyword IS NULL OR p_search_keyword = '' THEN
            SET v_where_clause = '';
        ELSE
            SET v_where_clause = CONCAT(' WHERE ticketnum LIKE ''%', p_search_keyword, '%'' OR id LIKE ''%', p_search_keyword, '%'' OR trainnum LIKE ''%', p_search_keyword, '%'' OR seatnum LIKE ''%', p_search_keyword, '%''');
        END IF;
        
        SET @sql = CONCAT('SELECT COUNT(*) AS total FROM ticket', v_where_clause);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END$$
    DELIMITER ;
    
    
    
    
    
    
-- 权限代理服务 - 数据库表创建脚本
-- 用于存储用户权限提升请求

CREATE TABLE IF NOT EXISTS permission_request (
    request_id VARCHAR(50) PRIMARY KEY COMMENT '请求ID',
    user_id VARCHAR(50) NOT NULL COMMENT '用户ID',
    request_type VARCHAR(50) NOT NULL COMMENT '请求类型：user_manage, train_manage, ticket_manage, seat_manage, other',
    request_title VARCHAR(200) NOT NULL COMMENT '请求标题',
    request_content TEXT COMMENT '请求详细内容',
    request_params TEXT COMMENT '请求参数（JSON格式）',
    admin_role VARCHAR(50) COMMENT '分配的管理员角色：user_admin, train_admin, super_admin',
    assigned_admin VARCHAR(50) COMMENT '分配的管理员账号',
    status VARCHAR(20) DEFAULT 'pending' COMMENT '状态：pending待处理, processing处理中, completed已完成, rejected已拒绝',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    assign_time DATETIME COMMENT '分配管理员时间',
    complete_time DATETIME COMMENT '完成时间',
    result_content TEXT COMMENT '处理结果内容',
    result_data TEXT COMMENT '处理结果数据（JSON格式）',
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_admin_role (admin_role),
    INDEX idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='权限提升请求表';




    
  
    USE wanli_12306;
    -- 授予 user_admin 用户执行所有搜索存储过程的权限
    -- 授予搜索存储过程权限
    GRANT EXECUTE ON PROCEDURE wanli_12306.SEARCH_TRAIN_LIST TO 'user_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.SEARCH_USER_MANAGE TO 'user_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.SEARCH_TRAIN_MANAGE TO 'user_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.SEARCH_TRIP_MANAGE TO 'user_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.SEARCH_TICKET_MANAGE TO 'user_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.SEARCH_PERMISSION_REQUEST TO 'user_admin'@'%';
    
    -- 授予计数存储过程权限
    GRANT EXECUTE ON PROCEDURE wanli_12306.COUNT_TRAIN_LIST TO 'user_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.COUNT_USER_MANAGE TO 'user_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.COUNT_TRAIN_MANAGE TO 'user_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.COUNT_TRIP_MANAGE TO 'user_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.COUNT_TICKET_MANAGE TO 'user_admin'@'%';
    
    
    -- 授予 train_admin 用户执行存储过程的权限
    -- 授予搜索存储过程权限
    GRANT EXECUTE ON PROCEDURE wanli_12306.SEARCH_TRAIN_LIST TO 'train_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.SEARCH_TRAIN_MANAGE TO 'train_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.SEARCH_TRIP_MANAGE TO 'train_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.SEARCH_TICKET_MANAGE TO 'train_admin'@'%';
    
    -- 授予计数存储过程权限
    GRANT EXECUTE ON PROCEDURE wanli_12306.COUNT_TRAIN_LIST TO 'train_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.COUNT_TRAIN_MANAGE TO 'train_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.COUNT_TRIP_MANAGE TO 'train_admin'@'%';
    GRANT EXECUTE ON PROCEDURE wanli_12306.COUNT_TICKET_MANAGE TO 'train_admin'@'%';
    
    
    -- 刷新权限
    FLUSH PRIVILEGES;
  