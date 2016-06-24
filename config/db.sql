CREATE TABLE `task` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '名称',
  `group` varchar(50) NOT NULL COMMENT '组',
  `file` varchar(100) NOT NULL COMMENT '程序文件',
  `class` varchar(20) NOT NULL COMMENT '类名',
  `method` varchar(20) NOT NULL COMMENT '方法名',
  `params` varchar(200) NOT NULL COMMENT '参数：json格式',
  `runtime` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '开始时间',
  `interval` int(10) unsigned NOT NULL DEFAULT '1' COMMENT '间隔时长 秒',
  `stat_time` int(10) unsigned NOT NULL COMMENT '开始时间',
  `end_time` int(10) unsigned NOT NULL COMMENT '结速时间',
  `flag` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT '标示  1：执行 2：暂停',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT '状态 1:启用  2:停用',
  `remarks` varchar(200) NOT NULL COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务';