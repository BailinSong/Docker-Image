#!/bin/sh

function check_config()
{
	echo "redis-trib.rb fix $1:$2"
	echo "Waiting All nodes agree about slots configuration"

	CONFIG_OK=""
	
	while [ -z "$CONFIG_OK" ]
	do 
		echo -n "#"
		sleep 1
		CONFIG_OK=$(redis-trib.rb fix $1:$2 | grep "All nodes agree about slots configuration")
	
	done
	
	echo "$CONFIG_OK"
}

function main()
{

	CLUSTER_NAME=""
	if [ -z "$1" ];then 
		CLUSTER_NAME="127.0.0.1"
	else
		CLUSTER_NAME=$1 
	fi

	START_PORT=""
	if [ -z "$2" ];then 
		START_PORT="7000"
	else
		START_PORT=$2 
	fi

	NODES=""
	if [ -z "$3" ];then 
		NODES="3"
	else
		NODES=$3 
	fi

	SLAVE_COUNT=""
	if [ -z "$4" ];then 
		SLAVE_COUNT="1"
	else
		SLAVE_COUNT=$4 
	fi

	

	TIMEOUT=""
	if [ -z "$5" ];then 
		TIMEOUT="30000"
	else
		TIMEOUT=$5 
	fi

	TRY_GET_INFO_MAX_COUNT=""
	if [ -z "$6" ];then 
		TRY_GET_INFO_MAX_COUNT="10"
	else
		TRY_GET_INFO_MAX_COUNT=$6 #30000
	fi

	TRY_COUNT="0"
	CLUSTER_IP=""
	CLUSTER_PORT=""
	CLUSTER_INFO=""
	REBALANCE="0"
	CONFIG_OK=""

	PORT=$((START_PORT-1))
	ENDPORT=$((PORT+NODES))
	LOCAL_LAN_IP=$(ifconfig |grep Bcast:|awk '{print $2}'|awk -F":" '{print $2}')

	# 获取服务节点名
	while [ $((TRY_COUNT<TRY_GET_INFO_MAX_COUNT)) != "0" ]&&[ -z "$CLUSTER_INFO" ]; do
		TRY_COUNT=$((TRY_COUNT+1))
		CLUSTER_INFO=$(redis-cli -h $CLUSTER_NAME -p $START_PORT cluster nodes 2>/dev/null);
		CLUSTER_IP=$(echo "$CLUSTER_INFO" | awk '{if(NR==1)print $2}'|awk -F"@" '{print $1}'|awk -F":" '{print$1}')
		CLUSTER_PORT=$(echo "$CLUSTER_INFO" | awk '{if(NR==1)print $2}'|awk -F"@" '{print $1}'|awk -F":" '{print$2}')
		echo "clusterID: $CLUSTER_IP:$CLUSTER_PORT"
	done

	# 创建Redis集群节点
	PORT=$((START_PORT-1))

	while [ $((PORT < ENDPORT)) != "0" ]; do
	    PORT=$((PORT+1))
	    echo "Starting $PORT"
	    redis-server --port $PORT --cluster-enabled yes --cluster-config-file nodes-${PORT}.conf --cluster-node-timeout $TIMEOUT --appendonly yes --appendfilename appendonly-${PORT}.aof --dbfilename dump-${PORT}.rdb --logfile ${PORT}.log --daemonize yes
	done

	# 判断自己是否在集群内
	LOCAL_NODEID=$(redis-cli -h $LOCAL_LAN_IP -p $START_PORT cluster nodes 2>/dev/null|grep -v myself |awk '{print $1}')
	if [ ! -z "$LOCAL_NODEID" ]; then
		LOCAL_NODEID=$(redis-cli -h $LOCAL_LAN_IP -p $START_PORT cluster nodes 2>/dev/null|awk '{print $1}')
		echo "arealy in cluster $LOCAL_NODEID"
	elif [ ! -z "$CLUSTER_IP" ]; then
	#集群已经存在
		echo "has cluster $CLUSTER_IP:$CLUSTER_PORT"
		#获取主从关系列表
		SLAVE_COUNT_BY_MASTERID=$(echo "$CLUSTER_INFO" | awk '{if($3=="master"||$3=="myself,master"){if(!sum[$1]>0){sum[$1]=0}}else{sum[$4]++}}END{for(i in sum)print sum[i] ":" i}' | sort)
		#解析要处理的IP行
		PORT=$((START_PORT-1))
		ROW_COUNT="0"
		while [ $((PORT < ENDPORT)) != "0" ]; do
			PORT=$((PORT+1))
			ROW_COUNT=$((ROW_COUNT+1))
			CSLAVE_COUNT=$(echo "$SLAVE_COUNT_BY_MASTERID" | awk -F":" '{if(NR=="'$ROW_COUNT'")print $1}')
			MASTER_NODEID=$(echo "$SLAVE_COUNT_BY_MASTERID" | awk -F":" '{if(NR=="'$ROW_COUNT'")print $2}')
			if [ $((CSLAVE_COUNT < $SLAVE_COUNT)) != "0" ]; then
				#以从节点身份加入集群
				echo "redis-trib.rb add-node --slave --master-id $MASTER_NODEID $LOCAL_LAN_IP:$PORT $CLUSTER_IP:$CLUSTER_PORT"
				redis-trib.rb add-node --slave --master-id $MASTER_NODEID $LOCAL_LAN_IP:$PORT $CLUSTER_IP:$CLUSTER_PORT
				
				check_config $CLUSTER_IP $CLUSTER_PORT

			else
				#以主节点身份加入集群
				echo "redis-trib.rb add-node $LOCAL_LAN_IP:$PORT $CLUSTER_IP:$CLUSTER_PORT"
				redis-trib.rb add-node $LOCAL_LAN_IP:$PORT $CLUSTER_IP:$CLUSTER_PORT
				
				check_config $CLUSTER_IP $CLUSTER_PORT

				REBALANCE="1"
			fi
		done
	else
	# 不存在任何集群
		echo "create cluster $LOCAL_NODEID"
		PORT=$((START_PORT-1))
		HOSTS=""
	    while [ $((PORT < ENDPORT)) != "0" ]; do
	        PORT=$((PORT+1))
	        HOSTS="$HOSTS $LOCAL_LAN_IP:$PORT"
	    done
	    echo "yes" | redis-trib.rb create --replicas 0 $HOSTS

	    check_config $LOCAL_LAN_IP $START_PORT
	   

	fi

	if [ $REBALANCE == "1" ]; then
		redis-trib.rb rebalance --threshold 1 --use-empty-masters $CLUSTER_IP:$CLUSTER_PORT
		
		check_config $CLUSTER_IP $CLUSTER_PORT
		
	fi
}
# main 127.0.0.1 7000 3 1 30000 10
main $1 $2 $3 $4 $5 $6