<template>
  <div>
    <TopNav></TopNav>
    <VidDetails :loading="loading" :title="title" :thumburl="thumbnail" :vurl="video_url" :churl="channel_url"></VidDetails>
    <b-container>
      <b-row>
        <b-col>
          <VidForm :resultsLoaded="results.length > 0" :leadMsg="leadMessage" :loading="loading" @formSubmitted="updateLoading" @updateQualityResults="updateResults"></VidForm>
        </b-col>
      </b-row>
      <b-row>
        <b-col>
          <QualityResults v-if="results.length > 0" :loading="loading" :results="results" :video_url="video_url" :best="best_results" @downloadStatus="downloadStatus"></QualityResults>
        </b-col>
      </b-row>
    </b-container>
  </div>
</template>

<script>
//import VideoBackground from 'vue-responsive-video-background-player'
    //<video-background
    //id="vidoe_bg"
    //:poster="require('@/assets/img_bg.jpg')"
    //:src="require('@/assets/video_bg.mp4')"
    //style="height: 100vh;"
    //overlay="linear-gradient(45deg,rgba(0,0,0,0.80),rgba(0,0,0,0.80))" 
    //></video-background>
import TopNav from './components/TopNav'
import VidForm from './components/VidForm'
import VidDetails from './components/VidDetails'
import QualityResults from './components/QualityResults'


export default {
  name: 'App',
  data() {
    return {
      title: "UNKNOWN",
      thumbnail: require('@/assets/loading_img.gif'),
      video_url: "",
      channel_url: "",
      best_results: [],
      results: [],
      loading: false,
      leadMessage: "Enter a video URL in the form below and submit for quality selection"
    }
  },
  components: {
    //VideoBackground,
    TopNav,
    VidForm,
    VidDetails,
    QualityResults
  },
  methods: {
    updateLoading(loading) {
      this.loading = loading;
      if (this.loading) {
        this.leadMessage = "Loading Results...";
      }else{
        this.leadMessage = "Enter a video URL in the form below and submit for quality selection";
      }
    },
    updateResults(results) {
      if (results.length == 0){
        this.title = "";
        this.thumbnail = require('@/assets/loading_img.gif');
        this.video_url = "";
        this.channel_url = "";
        this.results = [];
        this.best_results = [];
      }else{
        this.title = results.title;
        this.video_url = results.url;
        this.channel_url = results.channel_url;
        this.thumbnail = results.thumbnails.reduce((ary,obj) => (obj.id == "3" && ary.push(obj), ary), [])[0].url;
        this.results = results.full_formats.video.concat(results.full_formats.audio);
        this.best_results = results.best_formats;
      }
      this.updateLoading(false);
    },
    downloadStatus(status) {
      if (status){
        this.$bvToast.toast('The download successfully queued and will begin at the next availability.', {
          title: `Success`,
          variant: 'success',
          solid: true
        });
        this.updateResults([]);
      }else{
        this.$bvToast.toast('The download failed to queue, please contact the system administrator for help.', {
          title: `Error`,
          variant: 'warning',
          solid: true
        })
      }
    }
  }
}
</script>

<style>
body {
  background: url('./assets/img_bg.jpg');
  background-size: cover;
  background-color: #000000 !important;
}
#vidoe_bg {
  position: absolute;
  top: 0;
  left: 0;
}
</style>
