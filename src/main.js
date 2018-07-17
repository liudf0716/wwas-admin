import Vue from 'vue';
import App from './App';
import router from './router';
import axios from 'axios';
import ElementUI from 'element-ui';
import 'element-ui/lib/theme-default/index.css';    // 默认主题
 //import '../static/css/theme-green/index.css';       // 浅绿色主题
import "babel-polyfill";

Vue.use(ElementUI);
axios.defaults.withCredentials=true;

// axios.interceptors.response.use((response) => {
//     const data = response.data;
//     // const err = new Error(data.description);
//     switch (data.ret_code){
//         case '1001':
//             err.message = '请先登录';
//             location.replace('/login');
//                  return data
//     }
//
//
// })






Vue.prototype.$axios = axios;
new Vue({
    router,
    render: h => h(App)
}).$mount('#app');
