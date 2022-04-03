<template>
  <div>
    <b-sidebar id="video-details" title="Details" bg-variant="dark" text-variant="light" width="30vw" shadow>
      <div class="px-3 py-2 text-center">
        <b-img :src="thumburl" fluid thumbnail></b-img>
        <h6 id="vid_title">
          <marquee-text duration="15">{{title}}&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;</marquee-text>
        </h6>
        <b-button-group>
          <b-link :href="vurl" target="_BLANK"><b-button variant="primary"><b-icon-film></b-icon-film> Video</b-button></b-link>
          <b-link :href="churl" target="_BLANK"><b-button variant="primary"><b-icon-house-fill></b-icon-house-fill> Channel</b-button></b-link>
        </b-button-group>
      </div>
    </b-sidebar>
  </div>
</template>
<script>
import MarqueeText from 'vue-marquee-text-component'

export default {
  name: 'VidDetails',
  props: ['title','thumburl','vurl','churl'],
  data() {
    return {
      video_results: [],
      audio_results: [],
      best_results: [],
      results: []
    }
  },
  components: {
    MarqueeText
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
  #vid_title {
    padding: 10px 0px;
    margin-top: 10px;
    border-top: 2px solid;
    border-bottom: 2px solid;
  }
</style>