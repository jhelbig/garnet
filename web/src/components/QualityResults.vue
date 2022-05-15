<template>
  <b-table striped borderless outlined small dark hover v-bind:items="results" :fields="fields">
    <template #cell(id)="cell">
      <b-link href="#" v-on:click="downloadContent(cell.value)" title="Click to download">
        <b-badge variant="primary">
          <b-icon icon="download" variant="white" ></b-icon>
        </b-badge>
      </b-link>
    </template>
    <template #cell(resolution)="cell">
      <template v-if="cell.item.muxed">
        <b-badge :variant="cell.value.variant" :title="cell.value.title">
          <b-icon icon="camera-reels-fill"></b-icon>
          <b-icon icon="plus"></b-icon>
          <b-icon icon="soundwave"></b-icon>
        </b-badge>
      </template>
      <template v-else>
        <b-badge :variant="cell.value.variant" :title="cell.value.title">
          <b-icon :icon="cell.value.icon"></b-icon>
        </b-badge>
      </template>
    </template>
  </b-table>
</template>
<script>
export default {
  name: 'QualityResults',
  components: {
  },
  props: ['results', 'best', 'video_url'],
  data() {
    return {
      fields: [
        {
          key: "id",
          label: "",
          sortable: false,
          class: "text-center"
        },
        {
          key: "resolution",
          sortable: false,
          label: "File Type",
          class: "text-center",
          formatter: (value, key, item) => {
            let title = "";
            let variant = "secondary";
            if (item.muxed) {
              variant = "info";
              if (item.name == "Best") {
                title = "Best ";
              }
            }
            if (item.name == "Best" || this.best.map(data => data.id).includes(item.id)){
              variant = "warning";
              title = "Best ";
            }
            if (value == "Audio") {
              return {icon: "soundwave", title: `${title}Audio`, variant: variant, muxed: item.muxed};
            }else{
              if (item.muxed){
                return {icon: "camera-reels-fill", title: `${title}Audio & Video`, variant: variant, muxed: item.muxed};
              }else{
                return {icon: "camera-reels-fill", title: `${title}Video`, variant: variant, muxed: item.muxed};
              }
            }
          }
        },
        {
          key: "name",
          sortable: true,
          label: "Quality"
        },
        {
          key: "filesize",
          sortable: true,
          label:"Filesize",
          formatter: value => {
            return ((parseInt(value)/1024)/1024).toFixed(2)+" MB";
          }
        },
        {
          key: "extension",
          sortable: true,
          label:"Format"
        },
        {
          key: "quality_grade",
          sortable: true,
          label:"Qualty Score"
        }
      ]
    }
  },
  methods: {
    async downloadContent(cid) {
      fetch("http://localhost/video/download", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({youtube_url: this.video_url, format_id: cid})
      })
      .then(response => {
        if (response.status === 200) {
          this.$emit('downloadStatus', true);
        }else{
          this.$emit('downloadStatus', false);
        }
      })
    }
  }
}
</script>
<style>
  
</style>