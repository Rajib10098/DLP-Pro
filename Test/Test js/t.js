// ".thumbnail-and-metadata-wrapper" class name only has 1 

var thumbnailAndMetadataWrapper = document.querySelectorAll(".thumbnail-and-metadata-wrapper")[0]
var album_art = thumbnailAndMetadataWrapper.innerHTML.match(/(?<=src=")https:\/\/.+(?=\"\>)/)[0].replace(/&amp;/g, "&")
var album_name = thumbnailAndMetadataWrapper.innerText.match(/(?<=Album\s-\s).+/)[0]
var total_song = parseInt(thumbnailAndMetadataWrapper.innerText.match(/\d+(?=\svideos)/)[0])
var set_current_year = new Date()
var current_year = set_current_year.getFullYear()
var song_list = 0
var songtextdata = ""
console.log(album_art);
console.log(album_name);
console.log(total_song);

var song_list_con = document.getElementById("contents")
var artist_name = song_list_con.innerHTML.match(/(?<=style-target="tooltip">\n\s\s\n\s\s\s\s).+(?=\n)/g)
var year = song_list_con.innerHTML.match(/\d+(?=\syears\sago)/g)
var video_id = song_list_con.innerHTML.match(/(?<=ytd-playlist-video-renderer"\shref="\/watch\?v=).+(?=&amp;list)/g)
var processing_song_name = song_list_con.innerHTML.match(/(?<=\<h3).+\n.+\n.+\n.+\n.+/g)
// var song_name = processing_song_name.

for (let index = 0; index < total_song; index++) {
    var song_name = processing_song_name[index].match(/(?<=\n\s\s\s\s\s\s\s\s\s\s).+(?=\n\s\s\s\s\s\s\s\s\<\/a\>)/)[0]
    var released_year = 0
    var track = index + 1
    var song_url = `https://www.youtube.com/watch?v=${video_id[index]}`
    var artist = artist_name[index]
    if (year != null) {
        released_year = current_year - parseInt(year[index])
    } else {
        released_year = current_year
    }


    // console.log(track)
    // console.log(song_url);
    // console.log(released_year, artist);
    // console.log(song_name);
    // console.log(album_name)

    var song_output = `song_index=${track} album="${album_name}" album_image="${album_art}" song_name="${song_name}" song_link="${song_url}" artist_name="${artist}" year="${released_year}"`
    // console.log(song_output);
    songtextdata += `${song_output} \n`

}




console.log(songtextdata);
// console.log(video_id);
// console.log(processing_song_name);

// Create a Blob object from the text
var blob = new Blob([songtextdata], { type: 'text/plain' });

// Create a temporary URL for the Blob
var url = URL.createObjectURL(blob);

console.log(url)

var download_ancher = document.createElement("a")
download_ancher.download ="songdata.txt"
download_ancher.href = url
download_ancher.classList.add("download_song_data")
document.querySelectorAll("body")[0].appendChild(download_ancher)
document.querySelectorAll(".download_song_data")[0]
console.log()


