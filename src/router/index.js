import Vue from "vue";
import Router from "vue-router";

Vue.use(Router);

export default new Router({
    routes: [
        {
            path: "/",
            redirect: "/login",
        },
        {
            path: "/readme",
            component: (resolve) =>
                require(["../components/common/Home.vue"], resolve),
            children: [
                {
                    path: "/basetable",
                    component: (resolve) =>
                        require(["../components/page/BaseTable.vue"], resolve),
                },
                {
                    path: "/devstatus",
                    component: (resolve) =>
                        require(["../components/page/DevStatus.vue"], resolve), // vue-datasource组件
                },
                {
                    path: "/cltstatus",
                    component: (resolve) =>
                        require(["../components/page/CltStatus.vue"], resolve), // vue-datasource组件
                },
                {
                    path: "/devdetail",
                    component: (resolve) =>
                        require(["../components/page/DevDetail.vue"], resolve), // vue-datasource组件
                },
                {
                    path: "/approve",
                    component: (resolve) =>
                        require(["../components/page/Approve.vue"], resolve), // vue-datasource组件
                },
                {
                    path: "/firmware",
                    component: (resolve) =>
                        require(["../components/page/Firmware.vue"], resolve), // vue-datasource组件
                },
                {
                    path: "/eventlog",
                    component: (resolve) =>
                        require(["../components/page/EventLog.vue"], resolve), // vue-datasource组件
                },
                {
                    path: "/fwUpgrade",
                    component: (resolve) =>
                        require(["../components/page/FwUpgrade.vue"], resolve), // vue-datasource组件
                },
                {
                    path: "/operation",
                    component: (resolve) =>
                        require([
                            "../components/page/OperationLog.vue",
                        ], resolve),
                },
                {
                    path: "/authlog",
                    component: (resolve) =>
                        require(["../components/page/AuthLog.vue"], resolve),
                },
                {
                    path: "/sysinfo",
                    component: (resolve) =>
                        require(["../components/page/Sysinfo.vue"], resolve),
                },
            ],
        },
        {
            path: "/login",
            component: (resolve) =>
                require(["../components/page/Login.vue"], resolve),
        },
        {
            path: "/register",
            component: (resolve) =>
                require(["../components/page/Register.vue"], resolve),
        },
    ],
});
