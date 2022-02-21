<template>
  <b-table striped borderless outlined small dark hover v-bind:items="results" :fields="fields">
    <template #cell(id)="cell">
      <b-badge variant="primary">
        <b-link :href="'#'+cell.value" title="Click to download">
          <b-icon icon="download" variant="white" ></b-icon>
        </b-link>
      </b-badge>
    </template>
    <template #cell(resolution)="cell">
      <template v-if="cell.item.muxed">
        <b-badge variant="info" title="Video & Audio">
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
  props: ['results', 'best'],
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
            key;
            let title = "";
            let variant = "secondary";
            console.log(this.best);
            console.log(item);
            if (this.best.map(data => data.id).includes(item.id)){
              variant = "warning";
              title = "Best ";
            }
            if (value == "Audio") {
              return {icon: "soundwave", title: `${title}Audio`, variant: variant, muxed: item.muxed};
            }else{
              return {icon: "camera-reels-fill", title: `${title}Video`, variant: variant, muxed: item.muxed};
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
          label:"Video Grade"
        }
      ]
    }
  }
}
</script>
<style>
  
</style>