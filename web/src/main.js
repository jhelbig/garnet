import Vue from 'vue'
import { BootstrapVue, IconsPlugin, LayoutPlugin } from 'bootstrap-vue'

import App from './App.vue'

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

Vue.config.productionTip = false
Vue.use(BootstrapVue)
Vue.use(LayoutPlugin)
Vue.use(IconsPlugin)

new Vue({
  render: h => h(App),
}).$mount('#app')
