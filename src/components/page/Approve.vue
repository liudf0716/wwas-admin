<template>
  <div v-loading="loading">
    <div class="crumbs">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><i class="el-icon-mobile-phone"></i> 认证管理</el-breadcrumb-item>
        <el-breadcrumb-item>设置</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div class="rad-group mb40">
      <el-tabs v-model="task_type">
        <el-tab-pane label="微信支付上网" name="wxpay_setting">
          <div class="form-box tab-cont form-box2">
            <el-form ref="form_wxpay" :model="forms.wxpay" :rules="rules.wxpay" label-width="150px">
              <el-form-item label="商户号" prop="mch_id">
                <el-input v-model="forms.wxpay.mch_id" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="商户证书序列号" prop="mch_serial_no">
                <el-input v-model="forms.wxpay.mch_serial_no" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="商户APIv3密钥" prop="mch_v3_key">
                <el-input v-model="forms.wxpay.mch_v3_key" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="商户API私钥文件" prop="mch_priv_key">
                <el-upload
                  class="upload-demo"
                  :action="upload.wxpayKey.url"
                  name="file_name"
                  :with-credentials="true"
                  list-type="text"
                  :beforeUpload="beforeWxpayUpload"
                  :on-success="uploadSuccess"
                  :file-list="upload.wxpayKey.fileList"
                  :auto-upload="true"
                  :limit="1"
                >
                  <el-button slot="trigger" size="small" type="primary">选取商户私钥</el-button>
                  <div slot="tip" class="el-upload__tip">上传商户私钥文件,大小不能超过128K</div>
                </el-upload>
              </el-form-item>
              <el-form-item label="微信支付平台证书" prop="wx_cert">
                <el-upload
                  class="upload-demo"
                  :action="upload.wxpayCert.url"
                  name="file_name"
                  :with-credentials="true"
                  list-type="text"
                  :beforeUpload="beforeWxpayUpload"
                  :on-success="uploadSuccess"
                  :file-list="upload.wxpayCert.fileList"
                  :auto-upload="true"
                  :limit="1"
                  accept=".crt,.pem,.cer"
                >
                  <el-button slot="trigger" size="small" type="primary">选取微信支付平台证书</el-button>
                  <div slot="tip" class="el-upload__tip">上传微信支付平台证书文件, 大小不能超过128K</div>
                </el-upload>
              </el-form-item>
              <el-form-item label="AppID" prop="app_id">
                <el-input v-model="forms.wxpay.app_id" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="支付金额" prop="amount">
                <el-input v-model="forms.wxpay.amount" class="diainp"></el-input>
                <span style="padding: 5px 12px">元</span>
              </el-form-item>
              <el-form-item label="支付完成通知域名" prop="notify_domain">
                <el-input v-model="forms.wxpay.notify_domain" class="diainp" @input="updateNotifyUrl"></el-input>
                <div class="text">
                  <p>
                    支付完成通知域名是微信支付完成后的回调地址<br />
                    用于接收微信支付结果通知。<br />
                    支付通知url为: <code>{{ forms.wxpay.notify_url }}</code>
                  </p>
                </div>
              </el-form-item>
              <el-form-item label="描述" prop="desc">
                <el-input v-model="forms.wxpay.desc" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="启用">
                <el-switch v-model="forms.wxpay.enable" class="diainp"></el-switch>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="onSaveSubmit('form_wxpay')">保存配置</el-button>
              </el-form-item>
            </el-form>
          </div>
        </el-tab-pane>

        <el-tab-pane label="一键免认证" name="onekey_setting">
          <div class="form-box tab-cont form-box2">
            <el-form ref="form_onekey" :model="forms.onekey" label-width="150px">
              <el-form-item label="启用">
                <el-switch v-model="forms.onekey.enable" class="diainp"></el-switch>
              </el-form-item>
              <el-form-item label="服务端放行">
                <el-switch v-model="forms.onekey.from_server" class="diainp"></el-switch>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="onSaveSubmit('form_onekey')">保存配置</el-button>
              </el-form-item>
            </el-form>
          </div>
        </el-tab-pane>

        <el-tab-pane label="用户密码认证" name="user_setting">
          <div class="form-box tab-cont form-box2">
            <el-form ref="form_user" :model="forms.user" :rules="rules.user" label-width="150px">
              <el-form-item label="用户名" prop="username">
                <el-input v-model="forms.user.username" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="用户密码" prop="password">
                <el-input v-model="forms.user.password" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="启用">
                <el-switch v-model="forms.user.enable" class="diainp"></el-switch>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="onSaveSubmit('form_user')">保存配置</el-button>
              </el-form-item>
            </el-form>
          </div>
        </el-tab-pane>

        <el-tab-pane label="短信认证" name="sms_setting">
          <el-form class="form-box tab-cont form-box2" label-width="150px">
            <el-form-item label="短信服务商">
              <el-select v-model="dxchoose" placeholder="请选择短信服务商" @change="changeDxchoose">
                <el-option label="阿里云" value="ali"></el-option>
                <el-option label="网易云信" value="wy"></el-option>
                <el-option label="无短信认证" value="none"></el-option>
              </el-select>
            </el-form-item>
            <!-- Removed nested el-form with ref="form_dx" as forms.dx is empty and ref is unused -->
            <el-form ref="form_ali" :model="forms.ali" :rules="rules.ali" label-width="150px" v-show="dxchoose == 'ali'">
              <el-form-item label="AccessKeyId" prop="app_id">
                <el-input v-model="forms.ali.app_id" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="AccessKeySecret" prop="app_secret">
                <el-input v-model="forms.ali.app_secret" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="SignName" prop="sms_sign_name">
                <el-input v-model="forms.ali.sms_sign_name" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="TemplateCode" prop="sms_template_code">
                <el-input v-model="forms.ali.sms_template_code" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="启用">
                <el-switch v-model="forms.ali.enable" class="diainp"></el-switch>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="onSaveSubmit('form_ali')">保存配置</el-button>
              </el-form-item>
            </el-form>
            <el-form ref="form_wy" :model="forms.wy" :rules="rules.wy" label-width="150px" v-show="dxchoose == 'wy'">
              <el-form-item label="AppKey" prop="app_id">
                <el-input v-model="forms.wy.app_id" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="AppSecret" prop="app_secret">
                <el-input v-model="forms.wy.app_secret" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="TemplateId" prop="template_id">
                <el-input v-model="forms.wy.template_id" class="diainp"></el-input>
              </el-form-item>
              <el-form-item label="启用">
                <el-switch v-model="forms.wy.enable" class="diainp"></el-switch>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="onSaveSubmit('formWy')">保存配置</el-button>
              </el-form-item>
            </el-form>
            <el-form ref="formNone" :model="forms.none" label-width="150px" v-show="dxchoose == 'none'">
              <el-form-item>
                <el-button type="primary" @click="onSaveSubmit('formNone')">保存配置</el-button>
              </el-form-item>
            </el-form>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="基本设置" name="base_setting">
          <div class="form-box tab-cont form-box2 flex-container">
            <div class="left-side">
              <el-form ref="form_base" :model="forms.base" :rules="rules.base" label-width="150px">
                <el-form-item label="跳转" prop="portal_url">
                  <el-input v-model="forms.base.portal_url" class="diainp"></el-input>
                </el-form-item>
                <el-form-item label="时间" prop="duration">
                  <el-select v-model="forms.base.duration" class="diainp" placeholder="请选择" @change="changeDuration">
                    <el-option v-for="item in durations" :key="item.value" :label="item.label" :value="item.value"> </el-option>
                  </el-select>
                </el-form-item>
                <el-form-item label="客户超时认证时间" prop="client_timeout">
                  <el-select v-model="forms.base.client_timeout" class="diainp" placeholder="请选择" @change="changeClientTimeout">
                    <el-option v-for="item in client_timeout_op" :key="item.value" :label="item.label" :value="item.value"> </el-option>
                  </el-select>
                </el-form-item>
                <el-form-item label="背景图片" prop="background_url">
                  <el-upload
                    class="upload-demo"
                    :action="upload.bgImage.url"
                    name="file_name"
                    :with-credentials="true"
                    list-type="picture"
                    :limit="1"
                    :before-upload="beforeUpload"
                    :on-success="uploadSuccess"
                    :on-excceed="handleExceed"
                    accept="image/png,image/jpg"
                    :auto-upload="true"
                  >
                    <el-button slot="trigger" size="small" type="primary" v-if="upload.bgImage.fileList.length < 1">选取图片</el-button>
                    <div slot="tip" class="el-upload__tip">只能上传jpg/png文件,且不超过2M</div>
                  </el-upload>
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" @click="onSaveSubmit('form_base')">保存配置</el-button>
                </el-form-item>
              </el-form>
            </div>

            <div class="right-side">
              <!-- Phone preview for the background image -->
              <div v-if="forms.base.background_url" class="phone-preview" :style="{ backgroundImage: 'url(' + forms.base.background_url + ')' }">
                <div class="preview-button-container">
                  <button type="button" class="btn" v-show="forms.wxpay.enable">微信支付认证上网</button>
                  <button type="button" class="btn" v-show="forms.ali.enable">短信认证上网</button>
                  <button type="button" class="btn" v-show="forms.user.enable">密码认证上网</button>
                  <button type="button" class="btn" v-show="forms.onekey">一键上网</button>
                  <!-- <button type="button" class="btn" id="tmppass">临时放行</button> !-->
                  <p class="msg"><input type="checkbox" class="checkbox" id="checkbox" checked /> <label for="checkbox">已阅读并同意</label> <span class="xieyihref">上网服务条款</span></p>
                </div>
              </div>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<script>
// Component for managing various authentication and payment settings.
// Includes configurations for WeChat Pay, One-key access, User Password Auth,
// SMS Authentication (AliYun, WangYi), and Base Settings like portal URL and UI customizations.
import { baseUrl } from 'components/common/Global';
const WXPayNotifyPath = '/api/v1/wxpay/notify'; // Path for WeChat Pay notification URL
import { validateUrl, validateNum, validateTimeNum, validateSpace, validateMac, splitStr, validateAppId, formatMoney, convertMoney } from 'components/common/Helpers.js';

export default {
  data: function () {
    return {
      params: {}, // Holds parameters for API calls, especially for saving settings
      task_type: 'wxpay_setting', // Controls the active tab
      durations: [
        { value: 1, label: '1小时' },
        { value: 2, label: '2小时' },
        { value: 3, label: '3小时' },
        { value: 4, label: '4小时' },
        { value: 5, label: '5小时' },
        { value: 6, label: '6小时' },
        { value: 7, label: '7小时' },
        { value: 8, label: '8小时' },
        { value: 9, label: '9小时' },
        { value: 10, label: '10小时' },
        { value: 11, label: '11小时' },
        { value: 12, label: '12小时' }
      ],
      client_timeout_op: [
        { value: 2, label: '2分钟' },
        { value: 4, label: '4分钟' },
        { value: 6, label: '6分钟' },
        { value: 8, label: '8分钟' },
        { value: 10, label: '10分钟' },
        { value: 20, label: '20分钟' },
        { value: 30, label: '30分钟' },
        { value: 60, label: '1小时' },
        { value: 120, label: '2小时' },
        { value: 360, label: '6小时' }
      ],
      forms: {
        // Encapsulates all form data models, organized by feature.
        wxpay: {
          // WeChat Pay settings form model
          mch_id: '',
          mch_serial_no: '',
          mch_v3_key: '',
          mch_priv_key: '', // URL/path to the private key file
          wx_cert: '', // URL/path to the WeChat certificate file
          app_id: '',
          amount: '',
          notify_domain: '',
          notify_url: '', // Constructed dynamically: 'https://' + notify_domain + WXPayNotifyPath
          desc: '',
          enable: false,
          from_server: true // Indicates if WXPay is server-side initiated/verified
        },
        onekey: {
          // One-key authentication settings form model
          enable: true,
          from_server: true // Indicates if one-key auth is server-side managed
        },
        user: {
          // User password authentication settings form model
          username: 'apfree',
          password: 'apfree',
          enable: true,
          from_server: true // Indicates if user auth is server-side managed
        },
        base: {
          // Base settings form model (portal URL, session duration, client timeout, background image)
          portal_url: '',
          duration: 1,
          client_timeout: 20,
          background_url: '' // URL for the portal background image
        },
        dx: {}, // Placeholder for general SMS settings; not actively used for fields but part of structure.
        ali: {
          // AliYun SMS provider settings form model
          app_id: '',
          app_secret: '',
          sms_sign_name: '',
          sms_template_code: '',
          enable: false,
          from_server: true // Consistent 'from_server' pattern, may indicate server-side validation/use
        },
        wy: {
          // WangYi (NetEase) SMS provider settings form model
          app_id: '',
          app_secret: '',
          template_id: '',
          enable: false,
          from_server: true // Consistent 'from_server' pattern
        },
        none: {
          // Model representing the state when no SMS provider is chosen (disabling SMS auth)
          enable: false
        }
      },
      rules: {
        // Encapsulates all form validation rules, mirroring the 'forms' object structure.
        wxpay: {
          // Validation rules for WeChat Pay settings
          mch_id: [
            { required: true, message: '请输入商户号', trigger: 'blur' },
            { validator: validateNum, trigger: 'blur' }
          ],
          mch_serial_no: [{ required: true, message: '请输入商户API证书序列号', trigger: 'blur' }],
          mch_v3_key: [{ required: true, message: '请输入商户APIv3密钥', trigger: 'blur' }],
          mch_priv_key: [
            { required: true, message: '请上传商户私钥文件', trigger: 'blur' } // Validates presence of the key file URL
          ],
          wx_cert: [
            { required: true, message: '请上传微信支付平台证书', trigger: 'blur' } // Validates presence of the cert file URL
          ],
          app_id: [
            { required: true, message: '请输入公众号或者小程序AppID', trigger: 'blur' },
            { validator: validateAppId, trigger: 'blur' }
          ],
          amount: [
            { required: true, message: '请输入支付金额', trigger: 'blur' },
            { validator: validateNum, trigger: 'blur' }
          ],
          notify_domain: [{ required: true, message: '请输入通知域名', trigger: 'blur' }],
          desc: [{ required: true, message: '请输入支付描述', trigger: 'blur' }]
        },
        user: {
          // Validation rules for User Password Authentication settings
          username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
          password: [{ required: true, message: '请输入用户名密码', trigger: 'blur' }]
        },
        base: {
          // Validation rules for Base Settings
          portal_url: [{ required: true, message: '请输入跳转页面', trigger: 'blur' }],
          duration: [{ required: true, message: '请选择时长', trigger: 'change' }],
          client_timeout: [{ required: true, message: '选择客户超时认证时间', trigger: 'change' }]
          // background_url is not directly validated here via rules, its presence is handled by default values.
        },
        ali: {
          // Validation rules for AliYun SMS provider settings
          app_id: [{ required: true, message: '请输入AccessKeyId', trigger: 'blur' }],
          app_secret: [{ required: true, message: '请输入AccessKeySecret', trigger: 'blur' }],
          sms_sign_name: [{ required: true, message: '请输入SignName', trigger: 'blur' }],
          sms_template_code: [{ required: true, message: '请输入TemplateCode', trigger: 'blur' }]
        },
        wy: {
          // Validation rules for WangYi (NetEase) SMS provider settings
          app_id: [{ required: true, message: '请输入AppKey', trigger: 'blur' }],
          app_secret: [{ required: true, message: '请输入AppSecret', trigger: 'blur' }],
          template_id: [{ required: true, message: '请输入TemplateId', trigger: 'blur' }]
        }
      },
      upload: {
        // Manages file upload configurations and state for different upload types.
        bgImage: {
          // Configuration for background image upload
          url: baseUrl + '/setting/uploadBgImage', // API endpoint for image upload
          fileList: [], // Stores the list of files for the el-upload component (usually one image)
          data: {} // Additional data to be sent with the upload request, if any.
        },
        wxpayKey: {
          // Configuration for WeChat Pay private key file upload
          url: baseUrl + '/setting/uploadKey', // API endpoint for key upload
          fileList: [] // Stores the file list for el-upload
        },
        wxpayCert: {
          // Configuration for WeChat Pay certificate file upload
          url: baseUrl + '/setting/uploadCert', // API endpoint for cert upload
          fileList: [] // Stores the file list for el-upload
        }
      },
      dxchoose: 'none', // Currently selected SMS provider: 'ali', 'wy', or 'none'. Controls visibility of SMS config forms.
      loading: false // Boolean to control the loading state overlay for the entire component during async operations.
    };
  },
  created: function () {
    this.getData(); // Load initial settings when the component is created.
  },
  methods: {
    // Imported validation and helper functions
    validateUrl: validateUrl,
    validateNum: validateNum,
    validateTimeNum: validateTimeNum,
    validateSpace: validateSpace,
    validateMac: validateMac,
    splitStr: splitStr,
    validateAppId: validateAppId,
    formatMoney: formatMoney,
    convertMoney: convertMoney,

    /**
     * Constructs the WeChat Pay parameters object for saving settings.
     * @returns {object} WeChat Pay parameters.
     */
    _buildWxpayParams: function () {
      const self = this;
      if (self.forms.wxpay.enable) {
        return {
          appId: self.forms.wxpay.app_id,
          mchId: self.forms.wxpay.mch_id,
          mchSerialNo: self.forms.wxpay.mch_serial_no,
          mchV3Key: self.forms.wxpay.mch_v3_key,
          mchPrivKey: self.forms.wxpay.mch_priv_key,
          wxCert: self.forms.wxpay.wx_cert,
          amount: convertMoney(self.forms.wxpay.amount), // Ensure amount is in correct format (e.g., cents)
          notifyDomain: self.forms.wxpay.notify_domain,
          desc: self.forms.wxpay.desc,
          enable: self.forms.wxpay.enable
        };
      } else {
        return {
          enable: false // Only send enable status if WXPay is disabled
        };
      }
    },

    /**
     * Constructs the One-Key authentication parameters object for saving settings.
     * @returns {object} One-Key authentication parameters.
     */
    _buildOnekeyParams: function () {
      const self = this;
      if (self.forms.onekey.enable) {
        return {
          enable: self.forms.onekey.enable,
          fromServer: self.forms.onekey.from_server
        };
      } else {
        return {
          enable: false
        };
      }
    },

    /**
     * Constructs the User Password authentication parameters object for saving settings.
     * @returns {object} User Password authentication parameters.
     */
    _buildUserParams: function () {
      const self = this;
      // Only include full user details if enabled.
      if (self.forms.user.enable) {
        return {
          user: self.forms.user.username,
          password: self.forms.user.password,
          enable: self.forms.user.enable,
          fromServer: self.forms.user.from_server
        };
      } else {
        return {
          enable: false
        };
      }
    },

    /**
     * Constructs the SMS authentication parameters object based on the selected provider.
     * @returns {object} SMS authentication parameters.
     */
    _buildSmsParams: function () {
      const self = this;
      if (self.dxchoose == 'ali') {
        // AliYun SMS
        return {
          aliAppId: self.forms.ali.app_id,
          aliAppSecret: self.forms.ali.app_secret,
          aliSmsSignName: self.forms.ali.sms_sign_name,
          aliSmsTemplateCode: self.forms.ali.sms_template_code,
          selected: self.dxchoose,
          smsAliEnable: self.forms.ali.enable,
          smsWyEnable: false // Explicitly set other provider to false
        };
      } else if (self.dxchoose == 'wy') {
        // WangYi SMS
        return {
          wyAppId: self.forms.wy.app_id,
          wyAppSecret: self.forms.wy.app_secret,
          wyTemplateId: self.forms.wy.template_id,
          selected: self.dxchoose,
          smsWyEnable: self.forms.wy.enable,
          smsAliEnable: false // Explicitly set other provider to false
        };
      } else {
        // No SMS provider selected or 'none'
        return {
          smsAliEnable: false,
          smsWyEnable: false,
          selected: self.dxchoose // Keep selected value ('none')
        };
      }
    },

    /**
     * Constructs the Base settings parameters object for saving.
     * Includes portal URL, background image URL, session duration, and client timeout.
     * @returns {object} Base settings parameters.
     */
    _buildBaseParams: function () {
      const self = this;
      return {
        portalUrl: self.forms.base.portal_url,
        backgroundUrl: self.forms.base.background_url || '/static/img/lg_pic.png', // Default background if not set
        duration: self.forms.base.duration,
        clientTimeout: self.forms.base.client_timeout
      };
    },

    /**
     * Populates WeChat Pay form fields from fetched server data.
     * Also updates the file list for WeChat Pay key and certificate uploads.
     * @param {object} result - The 'extra' object from the API response containing settings data.
     */
    _assignWxpayData: function (result) {
      const self = this;
      self.forms.wxpay.app_id = result.wxpayAppId || '';
      self.forms.wxpay.mch_id = result.mchId || '';
      self.forms.wxpay.mch_serial_no = result.mchSerialNo || '';
      self.forms.wxpay.mch_v3_key = result.mchV3Key || '';
      self.forms.wxpay.mch_priv_key = result.mchPrivateKey || '';
      self.forms.wxpay.wx_cert = result.wxCert || '';
      self.forms.wxpay.amount = formatMoney(result.wxpayAmount || 1); // Format money from cents/smallest unit
      self.forms.wxpay.notify_domain = result.wxpayNotifyDomain || '';
      // Construct full notify URL, fallback to current hostname if domain not set (though domain is required by WXPay)
      self.forms.wxpay.notify_url = 'https://' + (self.forms.wxpay.notify_domain || window.location.hostname) + WXPayNotifyPath;
      self.forms.wxpay.desc = result.wxpayDesc || '';
      self.forms.wxpay.enable = result.wxpayEnable || false;

      // Populate file lists for el-upload components if URLs exist
      self.upload.wxpayKey.fileList = result.mchPrivateKey ? [{ name: 'mch_private_key.pem', url: result.mchPrivateKey }] : [];
      self.upload.wxpayCert.fileList = result.wxCert ? [{ name: 'wx_cert.pem', url: result.wxCert }] : [];
    },

    /**
     * Populates One-Key authentication form fields from fetched server data.
     * @param {object} result - The 'extra' object from the API response.
     */
    _assignOnekeyData: function (result) {
      const self = this;
      if (result.onekeyEnable) {
        self.forms.onekey.enable = true;
        self.forms.onekey.from_server = result.onekeyFromServerEnable || true;
      } else {
        self.forms.onekey.enable = false;
        self.forms.onekey.from_server = false;
      }
    },

    /**
     * Populates User Password authentication form fields from fetched server data.
     * @param {object} result - The 'extra' object from the API response.
     */
    _assignUserData: function (result) {
      const self = this;
      self.forms.user.username = result.user || 'apfree'; // Default username if not set
      self.forms.user.password = result.password || 'apfree'; // Default password if not set
      self.forms.user.enable = result.userEnable || false;
      // Note: self.forms.user.from_server is initialized in data() and managed by UI.
      // If API needs to control 'from_server' for user auth, it should be explicitly in 'result'.
    },

    /**
     * Populates SMS provider (AliYun, WangYi) form fields and selects the current provider based on fetched server data.
     * @param {object} result - The 'extra' object from the API response.
     */
    _assignSmsData: function (result) {
      const self = this;
      self.forms.ali.app_id = result.smsAliAppId || '';
      self.forms.ali.app_secret = result.smsAliAppSecret || '';
      self.forms.ali.sms_sign_name = result.smsAliSignName || '';
      self.forms.ali.sms_template_code = result.smsAliTemplateCode || '';
      self.forms.ali.enable = result.smsAliEnable || false;

      self.forms.wy.app_id = result.smsWyAppId || '';
      self.forms.wy.app_secret = result.smsWyAppSecret || '';
      self.forms.wy.template_id = result.smsWyTemplateId || '';
      self.forms.wy.enable = result.smsWyEnable || false;

      self.dxchoose = result.smsSelected || 'none'; // Set the active SMS provider tab
    },

    /**
     * Populates Base settings form fields (portal URL, duration, timeout, background image) from fetched server data.
     * Also updates the file list for the background image upload component.
     * @param {object} result - The 'extra' object from the API response.
     */
    _assignBaseData: function (result) {
      const self = this;
      self.forms.base.portal_url = result.portalUrl || '';
      self.forms.base.duration = result.duration || 1; // Ensure value is string for el-select
      self.forms.base.client_timeout = result.clientTimeout || 20; // Ensure value is string for el-select
      const backgroundUrl = result.backgroundUrl || '/static/img/lg_pic.png'; // Default background
      self.forms.base.background_url = backgroundUrl;

      // Populate file list for background image el-upload if a custom URL is set
      if (result.backgroundUrl && result.backgroundUrl !== '/static/img/lg_pic.png') {
        let fileName = 'background_image'; // Default filename
        try {
          // Attempt to extract filename from URL
          const urlParts = new URL(result.backgroundUrl);
          const pathParts = urlParts.pathname.split('/');
          fileName = pathParts[pathParts.length - 1] || fileName;
        } catch (e) {
          // Fallback for non-standard URLs or if URL parsing fails
          const pathParts = result.backgroundUrl.split('/');
          fileName = pathParts[pathParts.length - 1] || fileName;
        }
        self.upload.bgImage.fileList = [{ name: fileName, url: backgroundUrl }];
      } else {
        self.upload.bgImage.fileList = []; // Clear file list if no custom image or default is used
      }
    },

    /**
     * Handles the submission of a specific form section.
     * Validates the form, then constructs parameters using helper methods and calls the API to save settings.
     * @param {string} form_name - The ref name of the form to validate (e.g., 'form_wxpay', 'form_ali').
     */
    onSaveSubmit: function (form_name) {
      const self = this;
      // Validate the specific form section that triggered the save.
      self.$refs[form_name].validate(function (valid) {
        if (!valid) {
          return false; // Validation failed for the current form section.
        }

        // Initialize parameters for the API call.
        self.params = {};
        self.params.user_account = localStorage.getItem('ms_username'); // Include user account for authentication/logging

        // Build parameters from all form sections using helper methods.
        // This approach sends all settings configurations regardless of which section was saved.
        self.params.wxpay = self._buildWxpayParams();
        self.params.onekey = self._buildOnekeyParams();
        self.params.user = self._buildUserParams();
        self.params.sms = self._buildSmsParams();
        Object.assign(self.params, self._buildBaseParams()); // Merge base params into the main params object.

        self.loading = true; // Activate loading overlay
        // API call to save all settings.
        self.$axios.post(baseUrl + '/setting/saveSetting', self.params).then(function (res) {
          self.loading = false; // Deactivate loading overlay
          if (res.data.ret_code == '1001') {
            // Specific error code for session/auth issue
            self.$message({ message: res.data.extra, type: 'warning' });
            setTimeout(function () {
              self.$router.replace('login'); // Redirect to login page
            }, 2000);
          }
          if (res.data.ret_code == 0) {
            // Success
            self.$message({ message: res.data.extra, type: 'success' });
          } else {
            // Other errors reported by the server
            self.$message.error(res.data.extra);
          }
        });
      });
    },

    /**
     * Fetches existing settings from the server and populates the form fields.
     * Uses helper methods to assign data to respective parts of the `forms` object.
     */
    getData: function () {
      const self = this;
      const params = {
        user_account: localStorage.getItem('ms_username')
      };
      self.$axios.post(baseUrl + '/setting/getSetting', params).then(function (res) {
        if (res.data.ret_code == '1001') {
          // Session/auth issue
          self.$message({ message: res.data.extra, type: 'warning' });
          setTimeout(function () {
            self.$router.replace('login'); // Redirect to login page
          }, 2000);
        }
        if (res.data.ret_code == 0) {
          // Success
          const result = res.data.extra; // API response data containing all settings

          // Populate form data using helper methods
          self._assignWxpayData(result);
          self._assignOnekeyData(result);
          self._assignUserData(result);
          self._assignSmsData(result);
          self._assignBaseData(result);
        }
      });
    },

    /**
     * Updates the WeChat Pay notify URL when the notify domain input changes.
     * @param {string} e - The new value of the notify domain from the input event.
     */
    updateNotifyUrl: function (e) {
      const self = this;
      // Dynamically construct the full notification URL using the input and predefined path.
      self.forms.wxpay.notify_url = 'https://' + e + WXPayNotifyPath;
    },

    /**
     * Handles the change in selected SMS provider.
     * @param {string} e - The value of the selected SMS provider ('ali', 'wy', 'none').
     */
    changeDxchoose: function (e) {
      const self = this;
      self.dxchoose = e; // Update the reactive property to control visibility of provider-specific forms.
    },

    /**
     * Handles the change in selected duration for base settings.
     * Ensures the value is stored as a string for compatibility with el-select.
     * @param {*} value - The selected duration.
     */
    changeDuration: function (value) {
      console.log('select:', value);
      const self = this;
      self.forms.base.duration = value;
    },

    /**
     * Handles the change in selected client timeout for base settings.
     * Ensures the value is stored as a string for compatibility with el-select.
     * @param {*} value - The selected client timeout.
     */
    changeClientTimeout: function (value) {
      const self = this;
      self.forms.base.client_timeout = value;
    },

    /**
     * Validates the background image file before upload.
     * Checks if the file size is less than 2MB.
     * @param {File} file - The file to be uploaded.
     * @returns {boolean} False if validation fails (preventing upload), true otherwise.
     */
    beforeUpload: function (file) {
      const isLt2M = file.size / 1024 / 1024 < 2; // Check if size is less than 2MB

      if (!isLt2M) {
        this.$message({ message: '上传图片大小不能超过 2MB!', type: 'warning' });
        return false; // Prevent upload
      }

      return true; // Allow upload
    },

    /**
     * Validates WeChat Pay related files (key/certificate) before upload.
     * Checks if the file size is less than 128KB.
     * @param {File} file - The file to be uploaded.
     * @returns {boolean} False if validation fails (preventing upload), true otherwise.
     */
    beforeWxpayUpload: function (file) {
      const isLt128K = file.size / 1024 < 128; // Check if size is less than 128KB
      if (!isLt128K) {
        this.$message({ message: '上传文件大小不能超过 128KB!', type: 'warning' });
        return false; // Prevent upload
      }
      return true; // Allow upload
    },

    /**
     * Handles successful file uploads.
     * Updates the relevant form model properties with the URL of the uploaded file
     * and updates the file list for the corresponding el-upload component.
     * @param {object} response - The API response from the server.
     * @param {object} file - The file object that was uploaded (unused directly, info taken from response and fileList).
     * @param {Array} fileList - The list of files for the el-upload component, managed by Element UI.
     */
    uploadSuccess: function (response, file, fileList) {
      if (response.ret_code == 0) {
        // Upload was successful on the server
        const uploadType = response.extra && response.extra.type; // Type of upload (e.g., 'cert', 'key', 'bgImage')
        const fileUrl = response.extra && response.extra.url; // URL of the uploaded file

        switch (uploadType) {
          case 'cert': // WeChat Pay certificate
            this.forms.wxpay.wx_cert = fileUrl;
            this.upload.wxpayCert.fileList = fileList;
            break;
          case 'key': // WeChat Pay private key
            this.forms.wxpay.mch_priv_key = fileUrl;
            this.upload.wxpayKey.fileList = fileList;
            break;
          case 'bgImage': // Background image for portal page
            this.forms.base.background_url = fileUrl;
            this.upload.bgImage.fileList = fileList;
            break;
          default:
            console.error('Unknown upload type:', uploadType, 'File URL:', fileUrl);
            this.$message.error('上传文件类型错误: 未知的文件类型'); // Error message for unknown type
            break;
        }
      } else {
        // Server returned an error for the upload
        this.$message.error('上传失败: ' + response.extra); // Display server error message
      }
    },

    /**
     * Handles the case where the number of selected files exceeds the upload limit (typically 1 for these uploads).
     * @param {Array} files - The files being uploaded.
     * @param {Array} fileList - The current file list of the upload component.
     */
    handleExceed: function (files, fileList) {
      this.$message.error('只能上传一张图片');
    }
  }
};
</script>
<style scoped>
  .flex-container {
    display: flex; /* Enables flexbox layout */
  }

  .left-side {
    /* Area for form input fields */
    flex: 1; /* Takes up available space */
    padding-right: 80px; /* Spacing between form and preview */
  }

  .right-side {
    /* Area for the phone preview */
    flex: 1; /* Takes up available space */
    display: flex;
    justify-content: center; /* Center phone preview horizontally */
    align-items: center; /* Center phone preview vertically */
    padding-left: 80px; /* Spacing between form and preview */
  }

  /* Styles for the phone preview element in Base Settings tab */
  .phone-preview {
    width: 200px;
    height: 400px;
    border: 16px solid black; /* Simulates phone border */
    border-radius: 36px; /* Rounded corners for phone look */
    background-size: contain; /* Cover the area with the background image */
    background-position: center; /* Center the background image */
    background-repeat: no-repeat;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* Subtle shadow for depth */
    position: relative; /* For positioning pseudo-elements like notch/button */
    background-color: #fff; /* Default background if image is not set */
  }

  /* Simulates the "notch" or earpiece area on a modern phone */
  .phone-preview::before {
    content: '';
    position: absolute;
    width: 60px;
    height: 5px;
    background-color: #333; /* Dark color for notch */
    border-radius: 10px;
    top: 10px; /* Position at the top */
    left: 50%;
    transform: translateX(-50%); /* Center horizontally */
  }

  /* Simulates a home button or bottom bar element on a phone */
  .phone-preview::after {
    content: '';
    position: absolute;
    width: 35px;
    height: 35px;
    background-color: #333; /* Dark color for button */
    border-radius: 50%; /* Circular button */
    bottom: 20px; /* Position at the bottom */
    left: 50%;
    transform: translateX(-50%); /* Center horizontally */
  }

  /* General styling for margins, padding, and text */
  .steps-tit {
    margin-bottom: 30px;
  }
  .mb40 {
    margin-bottom: 40px;
  }
  .tab-cont {
    padding: 40px;
  }
  .diainp {
    width: 260px;
  } /* Standard input width */
  .diainp2 {
    width: 260px;
  } /* Another standard input width, if different styling needed */
  .inp100 {
    width: 100px;
  } /* Shorter input width */
  .form-box2 {
    width: 700px;
  } /* Width constraint for form boxes */
  .txt {
    width: 700px;
    padding-left: 40px;
    font-size: 15px;
    color: #666;
    margin-bottom: 30px;
  }
  .txt p {
    line-height: 36px;
  }
  .txt .txt-small span {
    display: block;
    margin-left: 20px;
    font-size: 14px;
    line-height: 26px;
  }
  .preview-button-container {
    display: flex;
    flex-direction: column; /* 垂直排列 */
    justify-content: center; /* 垂直居中 */
    align-items: center; /* 水平居中 */
    height: 100%; /* 撑满整个视口高度，也可改为固定高度 */
    gap: 5px;
  }
  .btn {
    width: 120px;
    height: 28px;
    display: block;
    margin: 0 auto 10px;
    text-align: center;
    line-height: 28px;
    color: #fff;
    background-color: #0abcdf;
    border-radius: 1px;
    border: 1px solid #000;
    text-decoration: none;
    font-size: 8px;
  }
  .msg {
    font-size: 7px;
  }
  .checkbox {
    width: 10px;
    height: 10px;
    vertical-align: middle;
  }
  .xieyihref {
    color: #11b8b9;
  }
</style>
