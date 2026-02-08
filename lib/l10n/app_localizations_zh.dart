// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Dash for CF';

  @override
  String get common_cancel => '取消';

  @override
  String get common_close => '关闭';

  @override
  String get common_copied => '已复制到剪贴板';

  @override
  String get common_copy => '复制';

  @override
  String get common_copyFailed => '复制失败';

  @override
  String get common_create => '创建';

  @override
  String get common_add => '添加';

  @override
  String get common_delete => '删除';

  @override
  String get common_deleted => '删除成功';

  @override
  String get common_edit => '编辑';

  @override
  String get common_error => '错误';

  @override
  String get common_loading => '加载中...';

  @override
  String get common_noData => '暂无数据';

  @override
  String get common_ok => '确定';

  @override
  String get common_refresh => '刷新';

  @override
  String get common_retry => '重试';

  @override
  String get common_save => '保存';

  @override
  String get common_workInProgress => '功能开发中，敬请期待！';

  @override
  String get common_clearSearch => '清除搜索';

  @override
  String get common_clearFilters => '清除筛选';

  @override
  String get common_all => '全部';

  @override
  String get common_none => '无';

  @override
  String get common_proxy => '代理';

  @override
  String get common_rootOnly => '仅根域';

  @override
  String get common_disable => '禁用';

  @override
  String get menu_dns => 'DNS';

  @override
  String get menu_analytics => '分析';

  @override
  String get menu_pages => 'Pages';

  @override
  String get menu_workers => 'Workers';

  @override
  String get menu_settings => '设置';

  @override
  String get menu_about => '关于';

  @override
  String get menu_debugLogs => '调试日志';

  @override
  String get menu_selectZone => '选择区域';

  @override
  String get menu_noZones => '无区域';

  @override
  String get tabs_records => '记录';

  @override
  String get tabs_analytics => '分析';

  @override
  String get tabs_settings => '设置';

  @override
  String get tabs_web => 'Web';

  @override
  String get tabs_security => '安全';

  @override
  String get tabs_cache => '缓存';

  @override
  String get zone_selectZone => '选择区域';

  @override
  String get zone_searchZones => '搜索区域...';

  @override
  String get zone_noZones => '未找到区域';

  @override
  String get zone_status_active => '已激活';

  @override
  String get zone_status_pending => '待处理';

  @override
  String get zone_status_initializing => '初始化中';

  @override
  String get zone_status_moved => '已迁移';

  @override
  String get zone_status_deleted => '已删除';

  @override
  String get zone_status_deactivated => '已停用';

  @override
  String get dns_records => 'DNS 记录';

  @override
  String get dns_filterAll => '全部';

  @override
  String get dns_searchRecords => '搜索记录...';

  @override
  String get dns_noRecords => '无 DNS 记录';

  @override
  String get dns_noRecordsDescription => '添加 DNS 记录以开始';

  @override
  String get dns_noRecordsMatch => '没有匹配筛选条件的记录';

  @override
  String get dns_selectZoneFirst => '请选择区域以查看记录';

  @override
  String get dns_addRecord => '添加记录';

  @override
  String get dns_editRecord => '编辑记录';

  @override
  String get dns_deleteRecord => '删除记录';

  @override
  String get dns_deleteConfirmTitle => '删除 DNS 记录？';

  @override
  String dns_deleteConfirmMessage(String name) {
    return '确定要删除 $name 吗？此操作无法撤销。';
  }

  @override
  String get dns_recordSaved => '记录保存成功';

  @override
  String get dns_recordDeleted => '记录删除成功';

  @override
  String get dns_recordDeletedUndo => '记录已删除。点击撤销。';

  @override
  String get dns_deleteRecordConfirmTitle => '删除记录？';

  @override
  String dns_deleteRecordConfirmMessage(String name) {
    return '确定要删除“$name”吗？';
  }

  @override
  String get record_type => '类型';

  @override
  String get record_name => '名称';

  @override
  String get record_nameHint => '名称或 @ 为根域';

  @override
  String get record_nameRequired => '名称为必填';

  @override
  String get record_content => '内容';

  @override
  String get record_contentRequired => '内容为必填';

  @override
  String get record_ttl => 'TTL';

  @override
  String get record_ttlAuto => '自动';

  @override
  String get record_priority => '优先级';

  @override
  String get record_proxied => '已代理';

  @override
  String get record_proxiedTooltip => '通过 Cloudflare 代理';

  @override
  String get record_dnsOnly => '仅 DNS';

  @override
  String get record_dnsOnlyTooltip => '仅 DNS（不代理）';

  @override
  String get analytics_title => 'DNS 分析';

  @override
  String get analytics_selectZone => '选择区域以查看分析';

  @override
  String get analytics_noData => '无分析数据';

  @override
  String get analytics_loadAnalytics => '加载分析';

  @override
  String get analytics_timeRange30m => '30m';

  @override
  String get analytics_timeRange6h => '6h';

  @override
  String get analytics_timeRange12h => '12h';

  @override
  String get analytics_timeRange24h => '24h';

  @override
  String get analytics_timeRange7d => '7d';

  @override
  String get analytics_timeRange30d => '30d';

  @override
  String get analytics_totalQueries => '查询总数';

  @override
  String get analytics_topQueryNames => '热门查询名称';

  @override
  String get analytics_clearSelection => '清除选择';

  @override
  String get analytics_total => '总计';

  @override
  String get analytics_queryTypes => '查询类型';

  @override
  String get analytics_dataCenters => '数据中心';

  @override
  String get analytics_queriesOverTime => '随时间的查询';

  @override
  String get analytics_queriesByDataCenter => '按数据中心的查询';

  @override
  String get analytics_queriesByLocation => '按位置的查询';

  @override
  String get analytics_queriesByRecordType => '按记录类型的查询';

  @override
  String get analytics_queriesByResponseCode => '按响应代码的查询';

  @override
  String get analytics_queriesByIpVersion => '按 IP 版本的查询';

  @override
  String get analytics_queriesByProtocol => '按协议的查询';

  @override
  String get analytics_topQueryNamesChart => '热门查询名称';

  @override
  String get analytics_requests => '请求';

  @override
  String get analytics_bandwidth => '带宽';

  @override
  String get analytics_uniqueVisitors => '独立访客';

  @override
  String get analytics_requestsByStatus => '按状态的请求';

  @override
  String get analytics_requestsByCountry => '按国家/地区的请求';

  @override
  String get analytics_geographicDistribution => '地理分布';

  @override
  String get analytics_requestsByProtocol => '按协议的请求';

  @override
  String get analytics_requestsByHost => '按主机的请求';

  @override
  String get analytics_topPaths => '热门路径';

  @override
  String get analytics_threatsStopped => '已阻止的威胁';

  @override
  String get analytics_totalThreatsBlocked => '被阻止的威胁总数';

  @override
  String get analytics_actionsTaken => '采取的操作';

  @override
  String get analytics_threatsByCountry => '按国家/地区的威胁';

  @override
  String get analytics_topThreatSources => '主要威胁来源';

  @override
  String get analytics_threatOrigins => '威胁来源';

  @override
  String get analytics_cacheHitRatio => '缓存命中率';

  @override
  String get analytics_bandwidthSaved => '节省的带宽';

  @override
  String get analytics_requestsCacheVsOrigin => '请求（缓存 vs 源站）';

  @override
  String get analytics_bandwidthCacheVsOrigin => '带宽（缓存 vs 源站）';

  @override
  String get analytics_cacheStatusByHttpStatus => '按 HTTP 状态的缓存状态';

  @override
  String get analytics_securityRequiresPaidPlan =>
      '安全分析需要付费的 Cloudflare 计划（Pro 或更高）。';

  @override
  String get dnsSettings_title => 'DNS 设置';

  @override
  String get dnsSettings_dnssec => 'DNSSEC';

  @override
  String get dnsSettings_dnssecDescription =>
      'DNS 安全扩展通过对 DNS 记录进行签名增加安全层，帮助保护您的域名免受 DNS 欺骗和缓存投毒攻击。';

  @override
  String get dnsSettings_dnssecDisabled => 'DNSSEC 已禁用';

  @override
  String get dnsSettings_dnssecPending => 'DNSSEC 正在激活中';

  @override
  String get dnsSettings_dnssecPendingCf =>
      'DNSSEC 将由 Cloudflare Registrar 自动配置';

  @override
  String get dnsSettings_dnssecActive => 'DNSSEC 已启用';

  @override
  String get dnsSettings_dnssecPendingDisable => 'DNSSEC 正在停用中';

  @override
  String get dnsSettings_enableDnssec => '启用 DNSSEC';

  @override
  String get dnsSettings_disableDnssec => '禁用 DNSSEC';

  @override
  String get dnsSettings_cancelDnssec => '取消';

  @override
  String get dnsSettings_viewDetails => '查看详情';

  @override
  String get dnsSettings_viewDsRecord => '查看 DS 记录';

  @override
  String get dnsSettings_dsRecord => 'DS 记录';

  @override
  String get dnsSettings_copyDsRecord => '复制 DS 记录';

  @override
  String get dnsSettings_dsRecordCopied => 'DS 记录已复制到剪贴板';

  @override
  String get dnsSettings_addDsToRegistrar => '将此 DS 记录添加到您的域名注册商以完成 DNSSEC 设置：';

  @override
  String get dnsSettings_multiSignerDnssec => '多签名 DNSSEC';

  @override
  String get dnsSettings_multiSignerDescription => '允许多个 DNS 提供商为您的区域签名';

  @override
  String get dnsSettings_multiProviderDns => '多提供商 DNS';

  @override
  String get dnsSettings_multiProviderDescription => '启用其他提供商的辅助 DNS';

  @override
  String get dnsSettings_cnameFlattening => 'CNAME 扁平化';

  @override
  String get dnsSettings_cnameFlatteningDescription => '在区域顶点扁平化 CNAME 记录';

  @override
  String get dnsSettings_cnameFlattenNone => '无';

  @override
  String get dnsSettings_cnameFlattenAtRoot => '仅根域扁平化';

  @override
  String get dnsSettings_cnameFlattenAll => '全部扁平化';

  @override
  String get dnsSettings_emailSecurity => '邮件安全';

  @override
  String get dnsSettings_emailSecurityDescription =>
      '配置 DMARC、SPF 和 DKIM 记录用于邮件认证';

  @override
  String get dnsSettings_configureEmail => '配置';

  @override
  String get dnsSettings_disableDnssecTitle => '禁用 DNSSEC？';

  @override
  String get dnsSettings_cancelDeactivation => '取消停用';

  @override
  String get emailSecurity_spfExists => 'SPF 记录已配置';

  @override
  String get emailSecurity_spfNotConfigured => 'SPF 未配置';

  @override
  String get emailSecurity_spfDescription =>
      '发件人策略框架（SPF）指定哪些邮件服务器有权代表您的域名发送邮件。';

  @override
  String get emailSecurity_spfIncludes => '授权发件人（includes）';

  @override
  String get emailSecurity_spfIncludesHint => '例如：_spf.google.com sendgrid.net';

  @override
  String get emailSecurity_spfPolicy => '策略（All）';

  @override
  String get emailSecurity_spfPolicyHint => '~all（软失败）、-all（硬失败）或 +all（允许）';

  @override
  String get emailSecurity_spfSaved => 'SPF 记录保存成功';

  @override
  String get emailSecurity_dkimExists => 'DKIM 记录已配置';

  @override
  String get emailSecurity_dkimNotConfigured => 'DKIM 未配置';

  @override
  String get emailSecurity_dkimDescription =>
      '域名密钥识别邮件（DKIM）为您的邮件添加数字签名，以验证其未被篡改。';

  @override
  String get emailSecurity_dkimSelector => '选择器';

  @override
  String get emailSecurity_dkimSelectorHint => '例如：default、google、mailgun';

  @override
  String get emailSecurity_dkimPublicKey => '公钥（p=）';

  @override
  String get emailSecurity_dkimPublicKeyHint =>
      '粘贴您的邮件提供商提供的公钥（不包含 v=DKIM1; k=rsa; p= 前缀）';

  @override
  String get emailSecurity_dkimPublicKeyRequired => '公钥为必填';

  @override
  String get emailSecurity_dkimSaved => 'DKIM 记录保存成功';

  @override
  String get emailSecurity_dmarcExists => 'DMARC 记录已配置';

  @override
  String get emailSecurity_dmarcNotConfigured => 'DMARC 未配置';

  @override
  String get emailSecurity_dmarcDescription =>
      '域名消息认证、报告与一致性（DMARC）告知接收服务器当 SPF 或 DKIM 校验失败时如何处理。';

  @override
  String get emailSecurity_dmarcPolicy => '策略';

  @override
  String get emailSecurity_dmarcPolicyHint => '认证失败时采取的操作';

  @override
  String get emailSecurity_dmarcPolicyNone => '无（仅监控）';

  @override
  String get emailSecurity_dmarcPolicyQuarantine => '隔离（标记为垃圾邮件）';

  @override
  String get emailSecurity_dmarcPolicyReject => '拒绝（阻止投递）';

  @override
  String get emailSecurity_dmarcRua => '汇总报告邮箱（rua）';

  @override
  String get emailSecurity_dmarcRuaHint => '例如：dmarc-reports@yourdomain.com';

  @override
  String get emailSecurity_dmarcRuf => '取证报告邮箱（ruf）';

  @override
  String get emailSecurity_dmarcRufHint => '可选：失败取证报告';

  @override
  String get emailSecurity_dmarcPct => '过滤邮件的百分比';

  @override
  String get emailSecurity_dmarcSaved => 'DMARC 记录保存成功';

  @override
  String get emailSecurity_preview => '预览';

  @override
  String get emailSecurity_recordName => '记录名称';

  @override
  String get dnssecDetails_title => 'DNSSEC 详情';

  @override
  String get dnssecDetails_dsRecord => 'DS 记录';

  @override
  String get dnssecDetails_digest => '摘要';

  @override
  String get dnssecDetails_digestType => '摘要类型';

  @override
  String get dnssecDetails_algorithm => '算法';

  @override
  String get dnssecDetails_publicKey => '公钥';

  @override
  String get dnssecDetails_keyTag => '密钥标签';

  @override
  String get dnssecDetails_keyType => '密钥类型';

  @override
  String get dnssecDetails_flags => '标志';

  @override
  String get dnssecDetails_modifiedOn => '修改时间';

  @override
  String get dnssecDetails_tapToCopy => '点击复制';

  @override
  String get settings_title => '设置';

  @override
  String get settings_apiToken => 'API 令牌';

  @override
  String get settings_apiTokenHint => '输入您的 Cloudflare API 令牌';

  @override
  String get settings_apiTokenDescription => '您的 API 令牌需要以下权限：';

  @override
  String get settings_apiTokenPermission1 => 'Zone:Read - 用于列出您的区域';

  @override
  String get settings_apiTokenPermission2 => 'DNS:Edit - 用于管理 DNS 记录';

  @override
  String get settings_apiTokenPermission3 =>
      'Zone Settings:Read - 用于 DNSSEC 状态';

  @override
  String get settings_apiTokenPermission4 => 'Zone Settings:Edit - 用于切换 DNSSEC';

  @override
  String get settings_apiTokenPermission5 => 'Analytics:Read - 用于 DNS 分析';

  @override
  String get settings_createToken => '在 dash.cloudflare.com 创建令牌';

  @override
  String get settings_tokenValid => '令牌有效';

  @override
  String get settings_tokenInvalid => '令牌至少需要 40 个字符';

  @override
  String get settings_tokenSaved => '令牌已保存';

  @override
  String get settings_goToDns => '前往 DNS';

  @override
  String get settings_theme => '主题';

  @override
  String get settings_themeLight => '浅色';

  @override
  String get settings_themeDark => '深色';

  @override
  String get settings_themeSystem => '自动';

  @override
  String get settings_amoledMode => 'AMOLED 纯黑';

  @override
  String get settings_amoledModeDescription => '暗色模式使用纯黑背景（在 OLED 屏幕上省电）';

  @override
  String get settings_language => '语言';

  @override
  String get settings_languageEn => 'English';

  @override
  String get settings_languagePt => 'Português';

  @override
  String get settings_languageZh => '中文';

  @override
  String get settings_about => '关于';

  @override
  String settings_version(String version) {
    return '版本 $version';
  }

  @override
  String get error_generic => '出现错误';

  @override
  String get error_network => '网络错误，请检查您的连接。';

  @override
  String get error_unauthorized => 'API 令牌无效或已过期';

  @override
  String get error_forbidden => '您没有权限访问此资源';

  @override
  String get error_notFound => '资源未找到';

  @override
  String get error_rateLimited => '请求过多，请稍后再试。';

  @override
  String get error_serverError => '服务器错误，请稍后再试。';

  @override
  String error_prefix(String message) {
    return '错误：$message';
  }

  @override
  String get error_copyError => '复制错误详情';

  @override
  String get error_permissionsRequired => '需要权限';

  @override
  String get error_permissionsDescription =>
      '您的 API 令牌没有访问此资源所需的权限。请检查 Cloudflare 控制台中的令牌设置。';

  @override
  String get error_checkCloudflareDashboard => '查看 Cloudflare 控制台';

  @override
  String get error_commonPermissionsTitle => '常见所需权限：';

  @override
  String get pwa_updateAvailable => '有新版本可用';

  @override
  String get pwa_updateNow => '立即更新';

  @override
  String get pwa_installApp => '安装应用';

  @override
  String get pwa_installDescription => '安装 Dash for CF 以便快速访问';

  @override
  String get settings_cloudflareApiToken => 'Cloudflare API 令牌';

  @override
  String get settings_requiredPermissions => '所需权限：Zone:Read、DNS:Read、DNS:Edit';

  @override
  String get settings_createTokenOnCloudflare => '在 Cloudflare 创建令牌';

  @override
  String get settings_tokenPastedFromClipboard => '已从剪贴板粘贴令牌';

  @override
  String get settings_storage => '存储';

  @override
  String get settings_clearCache => '清除缓存';

  @override
  String get settings_clearCacheDescription => 'DNS 记录、分析和数据中心';

  @override
  String get settings_clearCacheTitle => '清除缓存';

  @override
  String get settings_clearCacheMessage =>
      '这将清除所有缓存数据，包括 DNS 记录、分析和数据中心信息。\n\n下次访问时将从 API 重新加载数据。';

  @override
  String get settings_cacheCleared => '缓存已清除';

  @override
  String get settings_debug => '调试';

  @override
  String get settings_saveLogsToFile => '保存日志到文件';

  @override
  String get settings_saveLogsDescription => '保存日志以便之后分析';

  @override
  String get settings_viewDebugLogs => '查看调试日志';

  @override
  String get settings_goToDnsManagement => '前往 DNS 管理';

  @override
  String get debugLogs_title => '调试日志';

  @override
  String get debugLogs_copyAll => '全部复制';

  @override
  String get debugLogs_saveToFile => '保存到文件';

  @override
  String get debugLogs_shareAsText => '以文本分享';

  @override
  String get debugLogs_shareAsFile => '以文件分享';

  @override
  String get debugLogs_clearLogs => '清除日志';

  @override
  String get debugLogs_logsCopied => '日志已复制到剪贴板';

  @override
  String debugLogs_savedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String debugLogs_failedToSave(String error) {
    return '保存失败：$error';
  }

  @override
  String debugLogs_failedToShare(String error) {
    return '分享失败：$error';
  }

  @override
  String debugLogs_copyTimeRange(String timeRange) {
    return '复制 $timeRange';
  }

  @override
  String get debugLogs_logEntryCopied => '日志条目已复制';

  @override
  String get debugLogs_timeRange => '时间范围：';

  @override
  String get debugLogs_filter => '筛选：';

  @override
  String debugLogs_entries(int count) {
    return '$count 条记录';
  }

  @override
  String get debugLogs_noLogsInRange => '此时间范围内没有日志';

  @override
  String get debugLogs_tryLongerRange => '请尝试选择更长的时间范围';

  @override
  String get debugLogs_autoScrollOn => '自动滚动：开';

  @override
  String get debugLogs_autoScrollOff => '自动滚动：关';

  @override
  String get debugLogs_searchHint => '搜索日志...';

  @override
  String get dnsRecord_createTitle => '创建 DNS 记录';

  @override
  String get dnsRecord_editTitle => '编辑 DNS 记录';

  @override
  String get dnsRecord_recordCreated => '记录已创建';

  @override
  String get dnsRecord_recordUpdated => '记录已更新';

  @override
  String get dnsRecord_ttlAuto => '自动';

  @override
  String get dnsRecord_ttl2min => '2 分钟';

  @override
  String get dnsRecord_ttl5min => '5 分钟';

  @override
  String get dnsRecord_ttl10min => '10 分钟';

  @override
  String get dnsRecord_ttl15min => '15 分钟';

  @override
  String get dnsRecord_ttl30min => '30 分钟';

  @override
  String get dnsRecord_ttl1hour => '1 小时';

  @override
  String get dnsRecord_ttl2hours => '2 小时';

  @override
  String get dnsRecord_ttl5hours => '5 小时';

  @override
  String get dnsRecord_ttl12hours => '12 小时';

  @override
  String get dnsRecord_ttl1day => '1 天';

  @override
  String get dnsRecord_enterValue => '输入值';

  @override
  String emptyState_noResultsFor(String query) {
    return '没有“$query”的结果';
  }

  @override
  String get emptyState_tryAdjustingSearch => '尝试调整搜索条件';

  @override
  String get pages_title => 'Pages';

  @override
  String get pages_selectAccount => '选择账号';

  @override
  String get pages_noProjects => '未找到 Pages 项目';

  @override
  String pages_lastDeployment(String date) {
    return '上次部署：$date';
  }

  @override
  String get pages_statusSuccess => '成功';

  @override
  String get pages_statusFailed => '失败';

  @override
  String get pages_statusBuilding => '构建中';

  @override
  String get pages_statusQueued => '排队中';

  @override
  String get pages_statusSkipped => '已跳过';

  @override
  String get pages_statusUnknown => '未知';

  @override
  String get pages_openInBrowser => '在浏览器中打开';

  @override
  String get pages_deployments => '部署';

  @override
  String get pages_noDeployments => '未找到部署';

  @override
  String get pages_production => '生产环境';

  @override
  String get pages_preview => '预览';

  @override
  String get pages_deploymentDetails => '部署详情';

  @override
  String get pages_commitInfo => '提交信息';

  @override
  String get pages_buildStages => '构建阶段';

  @override
  String get pages_rollback => '回滚';

  @override
  String get pages_rollbackConfirmTitle => '回滚部署';

  @override
  String get pages_rollbackConfirmMessage => '确定要回滚到此部署吗？这会使该部署成为当前生产版本。';

  @override
  String get pages_rollbackSuccess => '回滚成功';

  @override
  String get pages_retry => '重试';

  @override
  String get pages_retryConfirmTitle => '重试部署';

  @override
  String get pages_retryConfirmMessage => '确定要重试此部署吗？这将以相同配置启动新的构建。';

  @override
  String get pages_retrySuccess => '已开始重试部署';

  @override
  String get pages_autoDeployPaused => '自动部署已暂停';

  @override
  String get pages_buildLogs => '构建日志';

  @override
  String get pages_noLogs => '暂无日志';

  @override
  String get pages_autoScrollOn => '自动滚动已开启';

  @override
  String get pages_autoScrollOff => '自动滚动已关闭';

  @override
  String pages_logCount(int current, int total) {
    return '$current / $total 行';
  }

  @override
  String get pages_customDomains => '自定义域名';

  @override
  String get pages_addDomain => '添加域名';

  @override
  String get pages_deleteDomainConfirmTitle => '删除自定义域名？';

  @override
  String pages_deleteDomainConfirmMessage(String domain) {
    return '确定要删除“$domain”吗？这将与您的 Pages 项目断开关联。';
  }

  @override
  String get pages_buildSettings => '构建设置';

  @override
  String get pages_buildCommand => '构建命令';

  @override
  String get pages_outputDirectory => '输出目录';

  @override
  String get pages_rootDirectory => '根目录';

  @override
  String get pages_environmentVariables => '环境变量';

  @override
  String get pages_productionEnv => '生产环境';

  @override
  String get pages_previewEnv => '预览环境';

  @override
  String get pages_addVariable => '添加变量';

  @override
  String get pages_variableName => '名称';

  @override
  String get pages_variableValue => '值';

  @override
  String get pages_secret => '密文';

  @override
  String get pages_plainText => '明文';

  @override
  String get pages_compatibilityDate => '兼容性日期';

  @override
  String get pages_compatibilityFlags => '兼容性标志';

  @override
  String get pages_saveSettings => '保存设置';

  @override
  String get pages_settingsUpdated => '设置更新成功';

  @override
  String get pages_domainAdded => '域名添加成功';

  @override
  String get pages_domainDeleted => '域名删除成功';

  @override
  String get pages_domainNameHint => 'example.com';

  @override
  String get pages_gitRepository => 'Git 仓库';

  @override
  String get pages_productionBranch => '生产分支';

  @override
  String get pages_automaticDeployments => '预览部署';

  @override
  String get pages_automaticDeploymentsDescription => '为预览分支自动部署';

  @override
  String get pages_productionDeployments => '生产部署';

  @override
  String get pages_productionDeploymentsDescription => '为生产分支自动部署';

  @override
  String get pages_prComments => 'PR 评论';

  @override
  String get pages_buildSystemVersion => '构建系统版本';

  @override
  String get pages_buildOutput => '构建输出';

  @override
  String get pages_buildComments => '构建注释';

  @override
  String get pages_buildCache => '构建缓存';

  @override
  String get pages_buildWatchPaths => '构建监视路径';

  @override
  String get pages_includePaths => '包含路径';

  @override
  String get pages_deployHooks => '部署钩子';

  @override
  String get pages_noDeployHooks => '未定义部署钩子';

  @override
  String get pages_runtime => '运行时';

  @override
  String get pages_placement => '部署位置';

  @override
  String get pages_usageModel => '计费模式';

  @override
  String get pages_bindings => '绑定';

  @override
  String get pages_addBinding => '添加绑定';

  @override
  String get pages_variableType => '类型';

  @override
  String get pages_variableSecret => '密文';

  @override
  String get pages_variablePlainText => '明文';

  @override
  String get pages_functionsBilling => 'Pages Functions 计费';

  @override
  String get pages_cpuTimeLimit => 'CPU 时间限制';

  @override
  String get pages_accessPolicy => '访问策略';

  @override
  String get pages_dangerZone => '危险区域';

  @override
  String get pages_deleteProject => '删除项目';

  @override
  String get pages_deleteProjectDescription =>
      '永久删除此 Pages 项目，包括所有部署、静态资源、函数和相关配置。';

  @override
  String get pages_deleteProjectConfirmTitle => '删除项目？';

  @override
  String pages_deleteProjectConfirmMessage(String project) {
    return '确定要删除 $project 吗？此操作无法撤销，并将删除所有部署。';
  }

  @override
  String get pages_projectDeleted => '项目删除成功';

  @override
  String get workers_title => 'Workers';

  @override
  String get workers_noWorkers => '未找到 Workers 脚本';

  @override
  String get workers_searchWorkers => '搜索 Workers...';

  @override
  String workers_lastModified(String date) {
    return '最后修改：$date';
  }

  @override
  String get workers_tabs_overview => '概览';

  @override
  String get workers_tabs_triggers => '触发器';

  @override
  String get workers_tabs_settings => '设置';

  @override
  String get workers_metrics_requests => '请求';

  @override
  String get workers_metrics_errors => '异常';

  @override
  String get workers_metrics_cpuTime => 'CPU 时间';

  @override
  String get workers_metrics_noData => '此期间无指标数据';

  @override
  String get workers_triggers_customDomains => '自定义域名';

  @override
  String get workers_triggers_routes => '路由';

  @override
  String get workers_triggers_addRoute => '添加路由';

  @override
  String get workers_triggers_addDomain => '添加自定义域名';

  @override
  String get workers_triggers_routePattern => '路由模式';

  @override
  String get workers_triggers_routePatternHint => 'example.com/*';

  @override
  String get workers_triggers_deleteRouteConfirm => '确定要删除此路由吗？';

  @override
  String get workers_triggers_deleteDomainConfirm => '确定要解绑此自定义域名吗？';

  @override
  String get workers_triggers_routeAdded => '路由添加成功';

  @override
  String get workers_triggers_routeDeleted => '路由删除成功';

  @override
  String get workers_triggers_domainAdded => '域名绑定成功';

  @override
  String get workers_triggers_domainDeleted => '域名解绑成功';

  @override
  String get workers_triggers_cron => 'Cron 触发器';

  @override
  String get workers_triggers_cronExpression => 'Cron 表达式';

  @override
  String get workers_triggers_cronFormat => '格式：分钟 小时 日 月 星期';

  @override
  String get workers_triggers_deleteScheduleConfirm => '确定要移除此 cron 触发器吗？';

  @override
  String get workers_triggers_noRoutes => '此区域未配置路由';

  @override
  String get workers_triggers_noSchedules => '未配置 cron 触发器';

  @override
  String get workers_triggers_domainManagedByCloudflare =>
      '域名必须由 Cloudflare 管理。';

  @override
  String get workers_triggers_zoneNotFound => '未找到该主机名对应的区域。';

  @override
  String get workers_settings_bindings => '绑定';

  @override
  String get workers_settings_variables => '环境变量';

  @override
  String get workers_settings_compatibility => '兼容性';

  @override
  String get workers_settings_usageModel => '计费模式';

  @override
  String get workers_bindings_kv => 'KV 命名空间';

  @override
  String get workers_bindings_r2 => 'R2 存储桶';

  @override
  String get workers_bindings_d1 => 'D1 数据库';

  @override
  String get workers_bindings_do => 'Durable Object';

  @override
  String get workers_bindings_service => '服务';

  @override
  String get workers_bindings_queue => '队列';

  @override
  String get workers_settings_addBinding => '添加绑定';

  @override
  String get workers_settings_bindingType => '类型';

  @override
  String get workers_settings_envVariable => '环境变量';

  @override
  String get workers_settings_bindingSecret => '密文';

  @override
  String get workers_settings_updateSecret => '更新密文';

  @override
  String get workers_settings_secretValue => '密文值';

  @override
  String get workers_settings_secretHint => '输入密文值（仅写入）';

  @override
  String get workers_settings_observability => '可观测性';

  @override
  String get workers_settings_logs => 'Workers 日志';

  @override
  String get workers_settings_traces => 'Workers 追踪';

  @override
  String get workers_settings_logpush => 'Logpush';

  @override
  String get workers_settings_tail => 'Tail Worker';

  @override
  String get workers_settings_tailDescription => '实时流式查看 Worker 日志';

  @override
  String get workers_settings_deleteWorker => '删除 Worker';

  @override
  String get workers_settings_deleteWorkerConfirm =>
      '确定要删除此 Worker 吗？此操作无法撤销，并将删除所有文件、配置和部署。';

  @override
  String get workers_settings_domainsAndRoutes => '域名与路由';

  @override
  String get workers_settings_build => '构建';

  @override
  String get workers_settings_gitIntegration => 'Git 集成';

  @override
  String get workers_settings_gitIntegrationDescription =>
      '在 Cloudflare 控制台配置 CI/CD';

  @override
  String get workers_settings_noAccountSelected => '未选择账号';

  @override
  String get workers_tail_title => 'Worker Tail 日志';

  @override
  String get workers_tail_connected => '已连接';

  @override
  String get workers_tail_connecting => '连接中...';

  @override
  String get workers_tail_disconnected => '已断开';

  @override
  String get workers_tail_start => '开始';

  @override
  String get workers_tail_stop => '停止';

  @override
  String get workers_tail_clear => '清除日志';

  @override
  String get workers_tail_autoScroll => '自动滚动';

  @override
  String get workers_tail_filterAll => '全部';

  @override
  String get workers_tail_filterLog => '日志';

  @override
  String get workers_tail_filterWarn => '警告';

  @override
  String get workers_tail_filterError => '错误';

  @override
  String workers_tail_logCount(int count) {
    return '$count 条日志';
  }

  @override
  String get workers_tail_noLogsYet => '暂无日志。触发您的 Worker 以查看日志。';

  @override
  String get workers_tail_notConnected => '未连接。点击开始以进行 Tail。';

  @override
  String get workers_settings_viewDomains => '查看域名';

  @override
  String get workers_settings_viewRoutes => '查看路由';

  @override
  String get workers_settings_pricing => '价格';
}
