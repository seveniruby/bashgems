redmine() {
    curl -s -H "Content-Type: application/json" \
        -H "X-Redmine-API-Key: 3c10cdf7818cdca2644a956d870e28b2a491d649" \
        "http://39.106.113.77:8888/$@"
}

#导入用户
import_user() {
    [ $# -eq 0 ] && line=$(</dev/stdin) || line="$@"
    echo "$line" | while read talk_name mail group; do
        id=$(redmine users.json -XPOST -d '
{
    "user": {
        "login": "'$mail'",
        "firsttalk_name": "hogwarts",
        "lasttalk_name": "'$talk_name'",
        "mail": "'$mail'",
        "password": "'${mail}'"
    }
}
' | jq -r '.user.id')
        echo $id
        [ -n "$group" ] && redmine "groups/$group/users.json" -XPOST -d '
{
  "user_id": '"$id"'
}
'
    done
}

#创建服务issue
issue_create() {
    [ $# -lt 3 ] && echo "issue_create project_id uid subject" && return
    local project_id=$1
    local uid=$2
    local subject=$3
    [ -z "$subject" ] && subject=职业发展咨询
    issue_find "assigned_to_id=$uid&project_id=$project_id"
    if ((issue_count == 0)); then
        redmine issues.json -XPOST -d '
{
  "issue": {
    "project_id": "'$project_id'",
    "subject": "'"$subject"'",
    "assigned_to_id": '$uid'
  }
}
'
    else
        echo "ERROR issue_id=$issue_id count=$issue_count"
    fi
}

#根据角色
get_uid() {
    local project=$1
    local role=$2
    local count=50
    local offset=0
    while ((count > 0)); do
        content=$(redmine "projects/${project}/memberships.json?offset=$offset&limit=$count")
        count=$(echo "$content" | jq '.memberships | length')
        ((offset += count))
        echo "$content" | jq '.memberships[] | select(.roles[0].talk_name=="'"$role"'") | .user.id' | grep -v null
    done
}

send_mail_to_role() {
    project=$1
    role=$2
    msg=$3
    get_uid $1 $2 | while read uid; do
        issue_find "project_id=$project&assigned_to_id=$uid"
        issue_note "$msg"
    done
}

issue_find() {
    issue_content=$(redmine "issues.json?$@")
    issue_id=$(echo "$issue_content" | jq -r '.issues[0].id')
    issue_count=$(echo "$issue_content" | jq '.total_count')
}
#发送通知
issue_note() {
    [ $# -eq 0 ] && echo "issue_note msg" && return
    if [ $issue_id != null ]; then
        redmine issues/$issue_id.json -XPUT -d '{"issue": {"notes": "'"$@"'" }}'
    else
        echo "error issue_id=$issue_id count=$issue_count $@"
    fi
}

issue_create_if_not_exist() {
    each_id=$1
    each_name=$2
    issue_find "issues.json?project_id=$project_id&cf_15=$each_id"
    if [ "$issue_id" = null ]; then
        local data='
{
  "issue": {
    "project_id": "'$project_id'",
    "subject": "'"$each_id $each_name"'",
    "assigned_to_id": '$uid',
    "custom_fields":[
        {"id":12,"name":"微信昵称","value":"'"$each_name"'"},
        {"id":14,"name":"所在群","value":"'"$talk_room"'"},
        {"id":15,"name":"微信id","value":"'$each_id'"}
    ]
  }
}
'
        redmine issues.json -XPOST -d "$data"
        issue_find "issues.json?project_id=$project_id&cf_15=$each_id"
    fi
}

issue_change_tracker() {
    issue_find "issues.json?project_id=$project_id&cf_15=$talk_id"
    local tracker_id=10
    redmine "issues/${issue_id}.json" -XPUT -d '
            { 
                "issue": { 
                "tracker_id": '$tracker_id',  
                "custom_fields":[ 
                    {"id":12, "name":"微信昵称", "value":"'"$talk_name"'"},
                    { "id":14, "name":"所在群", "value":"'"$talk_room"'"} 
                    ]
                }
            }'

}
chat() {
    local content="$@"
    echo "$content" >>/tmp/chat.log
    local uid=110
    local project_id=""

    local token=$(echo "$content" | jq -r '.data.token')
    if [ "$token" = '5ce60ee4377f5461bc9798a5' ]; then
        project_id=sales
    else
        project_id=testerhome_chat
    fi

    local talk_room=$(echo "$content" | jq -r '.data.roomTopic')
    local talk_name=$(echo "$content" | jq -r '.data.contactName')
    local talk_id=$(echo "$content" | jq -r '.data.contactId')
    local talk_text=$(echo "$content" | jq -r '.data.payload.text')
    local talk_content="$talk_room | $talk_name: $talk_text"
    local mention_id=$(echo "$content" | jq -r '.data.payload.mention[0]')
    [ "$mention_id" = null ] || {
        local mention_name=${talk_text%% *}
        mention_name=${mention_name#@}
    }
    if [ -z "$talk_room" ]; then
        mention_id="$token"
        mention_name="机器人"
    fi
    issue_create_if_not_exist $talk_id $talk_name
    issue_note "$talk_content"

    echo "$talk_room" | grep "咨询.*霍格" &>/dev/null && issue_change_tracker

    #todo: 将来可能会有多个at人
    echo -e "$mention_id $mention_name" | while read each_id each_name; do
        [ "$each_id" = null ] && continue
        issue_create_if_not_exist $each_id $each_name
        issue_note "$talk_content"
    done

}

cgi() {
    echo -e "Content-type: text/plain\n\n"
    echo $REQUEST_METHOD
    if [ "$REQUEST_METHOD" = "POST" ]; then
        read -n $CONTENT_LENGTH post
        . /root/redmine/redmine.sh
        chat "$post"
    fi
}

test_chat() {
    chat '{"data":{"messageId":"1669214560","chatId":"5cde899abd6faa1c4e19c49b","talk_roomTopic":"学员群-10期测试开发-霍格沃兹","talk_roomId":"9438271953@chattalk_room","contacttalk_Name":"石家庄-2-山长水远","contactId":"wxid_0rgcuauwbk9422","payload":{"text":"@霍格沃兹测试学院助教-歌舞升平 老师，有docker for MAC包么？","mention":["wxid_ly0llwqa8zzj22"]},"type":7,"timestamp":1563951585000,"token":"5ce60ee4377f5461bc9798a5"}}'
    chat '{"data":{"messageId":"1669214567","chatId":"5cde899abd6faa1c4e19c49b","talk_roomTopic":"学员群-10期测试开发-霍格沃兹","talk_roomId":"9438271953@chattalk_room","contacttalk_Name":"霍格沃兹测试学院助教-歌舞升平","contactId":"wxid_ly0llwqa8zzj22","payload":{"text":"brew cask install docker"},"type":7,"timestamp":1563951651000,"token":"5ce60ee4377f5461bc9798a5"}}'
    chat '{"data":{"messageId":"1669214572","chatId":"5cde899abd6faa1c4e19c49b","talk_roomTopic":"学员群-10期测试开发-霍格沃兹","talk_roomId":"9438271953@chattalk_room","contacttalk_Name":"霍格沃兹测试学院助教-歌舞升平","contactId":"wxid_ly0llwqa8zzj22","payload":{"text":"@石家庄-2-山长水远","mention":["wxid_0rgcuauwbk9422"]},"type":7,"timestamp":1563951678000,"token":"5ce60ee4377f5461bc9798a5"}}'

    chat '{"data":{"messageId":"1669214560","chatId":"5cde899abd6faa1c4e19c49b","talk_roomTopic":"咨询1群-10期测试开发-霍格沃兹","talk_roomId":"9438271953@chattalk_room","contacttalk_Name":"石家庄-2-山长水远","contactId":"wxid_0rgcuauwbk9422","payload":{"text":"@霍格沃兹测试学院助教-歌舞升平 老师，有docker for MAC包么？","mention":["wxid_ly0llwqa8zzj22"]},"type":7,"timestamp":1563951585000,"token":"5ce60ee4377f5461bc9798a5"}}'

}

update_version() {
    . /Users/seveniruby/projects/bashgems/lib/redmine.sh
    scp /Users/seveniruby/projects/bashgems/lib/redmine.sh root@docker.testing-studio.com:/root/redmine/
}
