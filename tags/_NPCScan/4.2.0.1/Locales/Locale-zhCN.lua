--[[****************************************************************************
  * _NPCScan by Saiket                                                         *
  * Locales/Locale-zhCN.lua - Localized string constants (zh-CN).              *
  ****************************************************************************]]


if ( GetLocale() ~= "zhCN" ) then
	return;
end


-- See http://wow.curseforge.com/addons/npcscan/localization/zhCN/
local _NPCScan = select( 2, ... );
_NPCScan.L = setmetatable( {
	NPCs = setmetatable( {
		[ 18684 ] = "独行者布罗加斯",
		[ 32491 ] = "迷失的始祖幼龙",
		[ 33776 ] = "古德利亚",
		[ 35189 ] = "逐日",
		[ 38453 ] = "阿克图瑞斯",
		[ 49822 ] = "Jadefang", -- Needs review
		[ 49913 ] = "雷蒂拉拉",
		[ 50005 ] = "Poseidus", -- Needs review
		[ 50009 ] = "魔布斯",
		[ 50050 ] = "索克沙拉克",
		[ 50051 ] = "鬼脚蟹",
		[ 50052 ] = "布尔吉·黑心",
		[ 50053 ] = "被放逐的萨图科",
		[ 50056 ] = "加尔",
		[ 50057 ] = "焰翼",
		[ 50058 ] = "泰罗佩内",
		[ 50059 ] = "格尔加洛克",
		[ 50060 ] = "泰博鲁斯",
		[ 50061 ] = "埃克萨妮奥娜",
		[ 50062 ] = "奥伊纳克斯",
		[ 50063 ] = "阿卡玛哈特",
		[ 50064 ] = "乌黑的赛勒斯",
		[ 50065 ] = "硕铠鼠",
		[ 50085 ] = "崩裂之怒主宰",
		[ 50086 ] = "邪恶的塔乌斯",
		[ 50089 ] = "厄运尤拉克",
		[ 50138 ] = "卡洛玛",
		[ 50154 ] = "梅迪克西斯（褐）",
		[ 50159 ] = "桑巴斯",
		[ 50409 ] = "神秘的骆驼雕像",
		[ 50410 ] = "神秘的骆驼雕像",
		[ 51071 ] = "弗罗伦斯船长",
		[ 51079 ] = "船长费尔温德",
		[ 51401 ] = "梅迪克西斯（红）",
		[ 51402 ] = "梅迪克西斯（绿）",
		[ 51403 ] = "梅迪克西斯（黑）",
		[ 51404 ] = "梅迪克西斯（蓝）",
	}, { __index = _NPCScan.L.NPCs; } );

	BUTTON_FOUND = "发现 NPC！",
	CACHED_FORMAT = "下列目标已经存入缓存：%s",
	CACHED_LONG_FORMAT = "下列目标已经存入缓存。请考虑使用 |cff808080“/npcscan”|r' 设置菜单将其移除，或通过清空缓存来重置：%s",
	CACHED_PET_RESTING_FORMAT = "下列可驯服宠物在休息时加入缓存：%s。",
	CACHED_STABLED_FORMAT = "以下怪物已被你驯服，无法继续侦测：%s。",
	CACHED_WORLD_FORMAT = "%2$s已经缓存：%1$s。",
	CACHELIST_ENTRY_FORMAT = "|cff808080“%s”|r",
	CACHELIST_SEPARATOR = "，",
	CMD_ADD = "ADD",
	CMD_CACHE = "CACHE",
	CMD_CACHE_EMPTY = "搜索的怪物均没有存入缓存。",
	CMD_HELP = "命令为 |cff808080“/npcscan add <NpcID> <名字>”|r、|cff808080“/npcscan remove <NpcID 或名字>”|r、|cff808080“/npcscan cache”|r列出已缓存的怪物，|cff808080“/npcscan”|r打开设置界面",
	CMD_REMOVE = "REMOVE",
	CMD_REMOVENOTFOUND_FORMAT = "NPC |cff808080“%s”|r未找到",
	CONFIG_ALERT = "警报选项",
	CONFIG_ALERT_SOUND = "警报音效文件",
	CONFIG_ALERT_SOUND_DEFAULT = "|cffffd200默认|r",
	CONFIG_ALERT_SOUND_DESC = "选择发现 NPC 时的警报音效，SharedMedia 插件可以提供更多额外音效。",
	CONFIG_ALERT_UNMUTE = "取消警报音效静音",
	CONFIG_ALERT_UNMUTE_DESC = "如果你静音了游戏则在找到 NPC 时解除静音。",
	CONFIG_CACHEWARNINGS = "在登录和切换区域时显示缓存提示",
	CONFIG_CACHEWARNINGS_DESC = "如果某个 NPC 在你登录或改变区域时已经在缓存中了，这一选项将显示一条关于已缓存怪物无法搜索的提示。",
	CONFIG_DESC = "这些选项可定制 _NPCScan 在找到稀有 NPC 时的警示方式。",
	CONFIG_PRINTTIME = "发送时间戳到聊天窗口",
	CONFIG_PRINTTIME_DESC = "发送消息添加当前时间。用于记录何时何地发现。",
	CONFIG_TEST = "测试警报",
	CONFIG_TEST_DESC = "模拟一次|cff808080“发现 NPC”|r警报让你知道它看起来什么样子。",
	CONFIG_TEST_HELP_FORMAT = "点击目标按钮或使用热键选定找到的怪物。按住|cffffffff<%s>|r并拖动可以移动目标按钮。注意，如果在战斗中发现 NPC，目标按钮只会在离开战斗后显示。",
	CONFIG_TEST_NAME = "你！（测试用）",
	CONFIG_TITLE = "_|cffCCCC88NPCScan|r",
	FOUND_FORMAT = "发现|cff808080“%s”|r！",
	FOUND_TAMABLE_FORMAT = "发现|cff808080“%s”|r！|cffff2020（注意：可驯服，可能是个玩家宠物。）|r",
	FOUND_TAMABLE_WRONGZONE_FORMAT = "|cffff2020错误警示：|r 发现可驯服宠物|cff808080“%s”|r，位于%s而不是%s（ID %d）；肯定是玩家宠物。",
	PRINT_FORMAT = "%s_|cffCCCC88NPCScan|r：%s",
	SEARCH_ACHIEVEMENTADDFOUND = "搜索已完成成就的 NPC",
	SEARCH_ACHIEVEMENTADDFOUND_DESC = "继续搜寻任何成就类 NPC，即使你已经不再需要它们。",
	SEARCH_ACHIEVEMENT_DISABLED = "已禁用",
	SEARCH_ADD = "+",
	SEARCH_ADD_DESC = "添加新 NPC 或保存改动。",
	SEARCH_ADD_TAMABLE_FORMAT = "注意：|cff808080“%s”|r可驯服，如果发现某个猎人的宠物是它的话会触发错误警示。",
	SEARCH_CACHED = "已缓存",
	SEARCH_COMPLETED = "完成",
	SEARCH_DESC = "这个表格可添加或移除需扫描的 NPC 和成就。",
	SEARCH_ID = "NPC ID：",
	SEARCH_ID_DESC = "要搜寻的 NPC 的 ID，这一数值可以在 Wowhead.com 等数据库找到。",
	SEARCH_MAP = "区域：",
	SEARCH_NAME = "名称：",
	SEARCH_NAME_DESC = "NPC 的标签，不一定要和 NPC 名字对应。",
	SEARCH_NPCS = "自定义 NPC",
	SEARCH_NPCS_DESC = "搜索任意 NPC，即便它没有相关成就",
	SEARCH_REMOVE = "-",
	SEARCH_TITLE = "搜索",
	SEARCH_WORLD = "世界：",
	SEARCH_WORLD_DESC = "一个可选的世界名称用来限制搜索。大陆可以是一个名称或|cffff7f3f副本名称|r（区分大小写）。",
	SEARCH_WORLD_FORMAT = "（%s）",
	TIME_FORMAT = "|cff808080[%H:%M:%S]|r ",
}, { __index = _NPCScan.L; } );


_G[ "BINDING_NAME_CLICK _NPCScanButton:LeftButton" ] = [=[选定最后一个找到的怪物
|cff808080（在_NPCScan 警报时使用）|r]=];