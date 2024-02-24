defmodule AmsycWeb.HomeLive do
  alias Amsyc.Accounts
  use AmsycWeb, :live_view

  alias Amsyc.Posts
  alias Amsyc.Posts.Post

  @impl true
  def render(%{loading: true} = assigns) do
    ~H"""
    Loading...
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    Hello!
    <.modal id="create-post-modal">
      <div id="form" phx-update="ignore">
        <.simple_form for={@form} phx-change="validate" phx-submit="save-post">
          <label for={@uploads.image.ref}>Image</label>
          <br />
          <.live_file_input upload={@uploads.image} />
          <.input field={@form[:title]} type="text" label="Title" />
          <.input
            field={@form[:embedded_media]}
            type="textarea"
            label="Embed Code (YouTube, ReverbNation, etc.)"
          />
          <.input field={@form[:body]} type="hidden" label="Body" id="trix-editor" />
          <trix-editor class="trix-content" input="trix-editor"></trix-editor>
          <.button type="submit" phx-disable-with="Saving...">Submit</.button>
        </.simple_form>
      </div>
    </.modal>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      user_token =
        case session do
          %{"user_token" => token} -> token
          _ -> nil
        end

      user_id = if user_token, do: Accounts.get_user_by_session_token(user_token), else: nil

      form =
        %Post{}
        |> Post.changeset(%{})
        |> to_form(as: "post")

      socket =
        socket
        |> assign(form: form, logged_in: !!user_token, user_id: user_id, loading: false)
        |> allow_upload(:image, accept: ~w(.png .jpg), max_entries: 1)

      {:ok, socket}
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  @impl true
  def handle_event("validate", _unsigned_params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save-post", %{"post" => post_params}, socket) do
    %{user_id: user} = socket.assigns

    post_params
    |> Map.put("user_id", user)
    |> Map.put("image", List.first(consume_files(socket)))
    |> Posts.create_post()
    |> case do
      {:ok, _post} ->
        socket =
          socket
          |> put_flash(:info, "Post created successfully!")
          |> push_navigate(to: ~p"/")

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  defp consume_files(socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
      dest = Path.join([:code.priv_dir(:amsyc), "static", "uploads", Path.basename(path)])
      File.cp!(path, dest)

      {:postpone, ~p"/uploads/#{Path.basename(dest)}"}
    end)
  end
end
