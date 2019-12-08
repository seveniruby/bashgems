log=/tmp/adb.log
echo "# $$ "$(date "+%Y/%m/%d %H:%M:%S") >> $log
echo "# ppid: $(ps -o command  $(ps -o ppid $$ | tail -1) | tail -1)" >> $log
echo "adb $@" >> $log
if echo "$@" | grep -E "logcat |exec-out |uiautomator runtest" &>/dev/null; then
  echo "exec" >> $log
  exec /Users/seveniruby/Library/Android/sdk//platform-tools/adb.bak "$@"
elif echo "$@" | grep "dumpsys package io.appium.settings" &>/dev/null; then
  echo "mock" >> $log
  cat /Users/seveniruby/temp/appium/package.mock | tee -a $log
elif echo "$@" | grep "io\.appium\.settings" &>/dev/null;then
  echo "mock" >> $log
  echo "11111" | tee -a $log
else
  result=$(/Users/seveniruby/Library/Android/sdk//platform-tools/adb.bak "$@")
  echo "origin" >> $log
  echo "$result" | tee -a $log
fi
echo "" >> $log