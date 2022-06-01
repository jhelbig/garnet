<template>
  <div>
    <b-jumbotron header="Garnet Video Downloader" :lead="leadMsg" bg-variant="dark" text-variant="white" border-variant="info">
      <b-form @submit="onSubmit" @reset="onReset">
        <b-form-group v-if="!loading"
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
              <b-button v-if="!resultsLoaded" type="submit" variant="primary"><b-icon v-if="loading" icon="arrow-clockwise" animation="spin-pulse" font-scale="1"></b-icon> Details</b-button>
              <b-button v-if="resultsLoaded && !loading" v-b-toggle.video-details :disabled="false">Video Details</b-button>
            </b-button-group>
            {{form.results}}
          </b-col>
          <b-col class="text-right">
            <b-button v-if="resultsLoaded && !loading" type="reset" variant="danger">Reset</b-button>
          </b-col>
        </b-row>
      </b-form>
    </b-jumbotron>
  </div>
</template>
<script>
import { BJumbotron, BForm, BFormGroup, BFormInput } from 'bootstrap-vue'

export default {
  name: 'VidForm',
  components: {
    BJumbotron,
    BForm,
    BFormGroup,
    BFormInput,
  },
  props: ['loading', 'resultsLoaded', 'leadMsg'],
  data() {
    return {
      form: {
        submitted: false,
        v_url: '',
        results: null
      }
    }
  },
  methods: {
    async onSubmit(event) {
      this.$emit('updateQualityResults', [])
      this.$emit('formSubmitted', true);
      event.preventDefault()
      fetch("/api/video/info", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({youtube_url: this.form.v_url})
      })
      .then(response => response.json())
      .then(data => {
        if (data.error) { throw data.error }
        data.best_formats.map(format => { (format.filesize/1024)/1024 });
        return data;
      })
      .then(data => (this.$emit('updateQualityResults', data)))
      .then(this.form.v_url = "")
      .catch(error => {
        this.$emit('updateQualityResults', []);
        this.$bvToast.toast(`Garnet failed to find information on the URL provided for the following reason: ${error}`, {
          title: `Error`,
          variant: 'danger',
          solid: true
        });
      });
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