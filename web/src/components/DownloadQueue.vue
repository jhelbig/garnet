<template>
  <div>
    <b-sidebar id="download-queue" title="Download Queue" bg-variant="dark" text-variant="light" width="30vw" right shadow>
      <div class="px-3 py-2 text-center">
        <b-table striped borderless outlined small dark hover v-bind:items="results" :fields="fields">
          <template #cell(id)="cell">
            <b-link v-if="!cell.item.downloading" href="#" v-on:click="deleteDownloadFromQueue(cell.value)" title="Click to remove from queue">
              <b-badge pill variant="danger">
                <b-icon icon="trash-fill" variant="white"></b-icon>
              </b-badge>
            </b-link>
            <b-badge v-else pill variant="info" title="Downloading">
              <b-icon icon="download" variant="white"></b-icon>
            </b-badge>
          </template>
          <template #cell(video_title)="cell">
            <b-link :href="cell.item.url" target="_BLANK" title="Watch Video">
              {{cell.value}}
            </b-link>
          </template>
        </b-table>
        
      
        <b-modal id="bv-modal-confirm-purge" hide-footer>
          <template #modal-title>
            Please Confirm
          </template>
          <div class="d-block text-center">
            <h2>
              <marquee-text duration=60>
                <b-icon icon="exclamation-triangle-fill" animation="throb"></b-icon>&nbsp;Warning&nbsp;
                <b-icon icon="exclamation-triangle-fill" animation="throb"></b-icon>&nbsp;Warning&nbsp;
                <b-icon icon="exclamation-triangle-fill" animation="throb"></b-icon>&nbsp;Warning&nbsp;
                <b-icon icon="exclamation-triangle-fill" animation="throb"></b-icon>&nbsp;Warning&nbsp;
              </marquee-text>
            </h2>
            <p>Are you absolutely sure you want to purge all items from the download queue?</p>
            <em class="note">This does not stop any videos currently being downloaded</em>
          </div>
          <b-button class="mt-3" block variant="warning" @click="purgeDownloadQueue">Confirm</b-button>
        </b-modal>
        
        
        <b-button-group>
          <b-button @click="$bvModal.show('bv-modal-confirm-purge')" variant="danger"><b-icon-exclamation-triangle-fill></b-icon-exclamation-triangle-fill> Purge Queue</b-button>
          <!--<b-button v-on:click="purgeDownloadQueue"  variant="warning"><b-icon-exclamation-triangle-fill></b-icon-exclamation-triangle-fill> Purge Queue</b-button>-->
        </b-button-group>
      </div>
    </b-sidebar>
  </div>
</template>
<script>
import MarqueeText from 'vue-marquee-text-component'

export default {
  name: 'DownloadQueue',
  props: [],
  data() {
    return {
      results: [],
      polling: null,
      fields: [
        {
          key: "id",
          label: "",
          sortable: false,
          class: "text-center"
        },
        {
          key: "video_title",
          label: "Title",
          sortable: true,
          class: "text-center"
        }
      ]
    }
  },
  components: {
    MarqueeText
  },
  created() {
    this.fetchDownloadQueueResults();
    this.polling = setInterval(() => {
      this.fetchDownloadQueueResults();
    }, 15000);
  },
  methods: {
    purgeDownloadQueue() {
      this.$bvModal.hide('bv-modal-confirm-purge');
      fetch("http://localhost/downloads/list", {
        method: "PURGE"
      })
      .then(response => response.json())
      .then(data => {
        this.results = data;
      })
    },
    deleteDownloadFromQueue(did) {
      fetch("http://localhost/downloads/list", {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({download_id: did})
      })
      .then(response => response.json())
      .then(data => {
        this.results = data;
      })
    },
    fetchDownloadQueueResults() {
      fetch("http://localhost/downloads/list", {
        method: "GET"
      })
      .then(response => response.json())
      .then(data => {
        this.results = data;
      }).then(() => {
        fetch("http://localhost/downloads/active", {
          method: "GET"
        })
        .then(response => response.json())
        .then(data => {
          if (Object.entries(data).length > 0){
            this.results.unshift(data);
          }
        })
      })
    }
  }
}
</script>
<style>
  a {
    color: white;
  }
  a:hover {
    color: #c0c0c0;
  }
  .note {
    font-size: 1vh;
  }
</style>