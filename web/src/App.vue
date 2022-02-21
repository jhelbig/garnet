<template>
  <div>
    <TopNav></TopNav>
    <b-container>
      <b-row>
        <b-col>
          <VidForm @updateQualityResults="updateResults"></VidForm>
        </b-col>
      </b-row>
      <b-row>
        <b-col>
          <QualityResults :results="results" :best="best_results"></QualityResults>
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
import QualityResults from './components/QualityResults'

export default {
  name: 'App',
  data() {
    return {
      video_results: [],
      audio_results: [],
      best_results: [],
      results: []
    }
  },
  components: {
    //VideoBackground,
    TopNav,
    VidForm,
    QualityResults
  },
  methods: {
    updateResults(results) {
      if (results.length == 0){
        this.results = [];
        this.best_results = [];
      }else{
        this.results = results.full_formats.video.concat(results.full_formats.audio);
        this.best_results = results.best_formats;
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
