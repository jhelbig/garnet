<template>
  <b-jumbotron header="Garnet Video Downloader" lead="Enter a video URL in the form below and submit for quality selection" bg-variant="dark" text-variant="white" border-variant="info">
    <b-form @submit="onSubmit" @reset="onReset">
      <b-form-group
        id="video-input-group"
        label-for="video-url"
        description="Other video streaming sources are also supported!"
      >
        <b-form-input
          id="video-url"
          v-model="form.v_url"
          type="url"
          placeholder="Paste Video Url"
          required
        ></b-form-input>
      </b-form-group>
      <b-row>
        <b-col class="text-left">
          <b-button-group>
            <b-button type="submit" variant="primary"><b-icon v-show="false" icon="arrow-clockwise" animation="spin-pulse" font-scale="1"></b-icon> Select Quality</b-button>
            <b-button type="submit" variant="info"><b-icon-download></b-icon-download> Best Quality</b-button>
          </b-button-group>
        </b-col>
        <b-col class="text-right">
          <b-button type="reset" variant="danger">Reset</b-button>
        </b-col>
      </b-row>
    </b-form>
  </b-jumbotron>
</template>
<script>
import { BJumbotron, BForm, BFormGroup, BFormInput } from 'bootstrap-vue'

export default {
  name: 'VidForm',
  components: {
    BJumbotron,
    BForm,
    BFormGroup,
    BFormInput
  },
  data() {
    return {
      form: {
        submitted: false,
        v_url: ''
      }
    }
  },
  methods: {
    async onSubmit(event) {
      this.form.submitted = true;
      event.preventDefault()
      // this is where an API call comes in
      fetch("http://localhost/video/info", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({youtube_url: this.form.v_url})
      })
      .then(response => response.json())
      .then(data => {
        data.best_formats.map(format => { (format.filesize/1024)/1024 });
        return data;
      })
      .then(data => (this.$emit('updateQualityResults', data)))
      .then(this.form.v_url = "")
      .then(this.form.submitted = false)
    },
    onReset(event) {
      event.preventDefault()
      // Reset our form values
      this.form.v_url= ''
      this.$emit('updateQualityResults', [])
    }
  }
}
</script>
<style>
  
</style>