%%------ 错误码
-define(fail, -1). %%
-define(ok, 0). %%
-define(insufficient_balance, 1). %% 余额不足
-define(bet_exceeds_limit, 2). %% 限红
-define(account_logged_another, 3). %% 异地登录

-define(invalid_verification_code, 4). %% 验证码错误
-define(is_already_linked, 5). %% 已绑定
-define(other_already_linked, 6). %% 被其他账号绑定
-define(invalid_password, 7). %% 密码错误
-define(invalid_email, 8). %% 无效邮箱
-define(invalid_phone, 9). %% 无效电话
-define(not_set_password_email, 10). %% 此游戏未设置密码
-define(not_set_password_phone, 11). %% 此游戏未设置密码


%%------ 阶段 ----
-define(preparation, 0). %% 准备 此阶段可以选择是否上庄
-define(dealing, 1). %% 发牌
-define(betting, 2). %% 下注
-define(settlement, 3). %% 结算


%%------ 区域 ----
-define(lucky_7, 0).
-define(super_lucky_7, 1).
-define(lucky_6, 2).
-define(lucky_6_2, 3).
-define(lucky_6_3, 4).
-define(banker_pair, 5).
-define(player_pair, 6).
-define(banker, 7).
-define(player, 8).
-define(tie, 9).


%%--- 登录方式
-define(login_with_guest, 0).
-define(login_with_email_password, 1).
-define(login_with_phone_password, 2).
-define(login_with_email_code, 3).
-define(login_with_phone_code, 4).

-record(heartbeat_req, {
    id
}).

-record(heartbeat_resp, {
    id,
    time
}).

-record(login_req, {
    option,   %% 登录方式
    email,
    phone,
    password,
    code      %% （游客模式，（手机，邮件）第一次请求 不用填写）
}).

-record(login_resp, {
    account,
    bonus_credits,  %% 体验金额
    real_money,     %% 真实金额
    reconnect_info
}).

-record(bind_email_req, {
    email,
    code
}).

-record(bind_email_resp, {
    code
}).

-record(bind_phone_req, {
    num,
    code
}).

-record(bind_phone_resp, {
    code
}).


-record(bind_password_req, {
    phone,
    email,
    password
}).

-record(bind_password_resp, {
    code
}).


-record(reconnect_info, {
    table_id,
    phase_info,
    bet_info
}).


%% 阶段变更信息
-record(phase_change_push,
{
    phase,
    cut_off_time,
    reset_the_road,
    deal_info,
    result     %% 结算阶段推送
}).

%% 下注请求
-record(betting_req,
{
    amount,
    zone
}).
%% 下注信息推送
-record(bet_push,
{
    is_self,
    amount,
    code
}).


-record(enter_room_req, {
    play_type,
    game_type
}).

-record(enter_room_resp, {
    play_type,
    game_type,
    phase_info
}).


-record(leave_room_req, {
}).

-record(leave_room_resp, {
    code
}).
