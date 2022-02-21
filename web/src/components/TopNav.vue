<template>
  <header>
    <b-navbar type="dark" variant="dark">
      <b-navbar-brand href="#">
        <b-img :src="require('@/assets/logo.png')" fluid width="32" height="32" alt="Garnet" title="Yargh!"></b-img>
      </b-navbar-brand>
      <b-navbar-nav>
        <b-nav-item href="https://www.youtube.com/" target="_BLANK"><b-icon-youtube style="color:red;"></b-icon-youtube> Youtube</b-nav-item>
  
        <!-- Navbar dropdowns -->
        <b-nav-item-dropdown text="Lang" right>
          <b-dropdown-item href="#">EN</b-dropdown-item>
          <b-dropdown-item href="#">ES</b-dropdown-item>
          <b-dropdown-item href="#">RU</b-dropdown-item>
          <b-dropdown-item href="#">FA</b-dropdown-item>
        </b-nav-item-dropdown>
  
        <b-nav-item-dropdown text="User" right>
          <b-dropdown-item href="#">Account</b-dropdown-item>
          <b-dropdown-item href="#">Settings</b-dropdown-item>
        </b-nav-item-dropdown>
      </b-navbar-nav>
    </b-navbar>
  </header>
</template>

<script>
import { BImg, BIconYoutube, BNavbar, BNavbarBrand, BNavbarNav, BNavItem, BNavItemDropdown, BDropdownItem } from 'bootstrap-vue'  

export default {
  name: 'TopNav',
  components: {
    BImg,
    BIconYoutube,
    BNavbar,
    BNavbarBrand,
    BNavbarNav,
    BNavItem,
    BNavItemDropdown,
    BDropdownItem
  },
  props: {
    msg: String
  }
}
</script>
<style scoped>
  header { margin-bottom: 20vh;}
</style>
